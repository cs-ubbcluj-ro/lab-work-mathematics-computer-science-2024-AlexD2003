#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <set>
#include <regex>
#include <string>
#include <algorithm>

struct Transition {
    std::string from;
    char symbol;
    std::string to;
};

void checkLexicalToken(const std::string &token) {
    static std::set<std::string> keywords = {
        "int", "float", "char", "if", "else", "while", "for", "return",
        "class", "void", "const", "new", "delete", "true", "false"
    };
    static std::set<std::string> operators = {
        "+", "-", "*", "/", "=", "==", "!=", "<", "<=", ">", ">=", "&&", "||", "!"
    };
    static std::set<char> separators = {';', ',', '(', ')', '{', '}', '[', ']', ' '};

    static std::regex identifierRegex(R"([a-zA-Z][a-zA-Z0-9]*)");
    static std::regex intRegex(R"([+-]?[0-9]+)");
    static std::regex charRegex(R"('([^\\]|\\.)')");
    static std::regex stringRegex(R"("([^"\\]|\\.)*")");

    if (keywords.count(token) > 0) {
        std::cout << token << " is a Keyword.\n";
    } else if (operators.count(token) > 0) {
        std::cout << token << " is an Operator.\n";
    } else if (std::regex_match(token, identifierRegex)) {
        std::cout << token << " is an Identifier.\n";
    } else if (std::regex_match(token, intRegex)) {
        std::cout << token << " is an Integer Constant.\n";
    } else if (std::regex_match(token, charRegex)) {
        std::cout << token << " is a Character Constant.\n";
    } else if (std::regex_match(token, stringRegex)) {
        std::cout << token << " is a String Constant.\n";
    } else if (token.length() == 1 && separators.count(token[0]) > 0) {
        std::cout << token << " is a Separator.\n";
    } else {
        std::cout << token << " is not a valid token.\n";
    }
}

int main(int argc, char *argv[]) {
    std::string input = argv[1];
    std::ifstream file(input);
    if (file.is_open()) {
        std::set<std::string> states;
        std::set<char> alphabet;
        std::vector<Transition> transitions;
        std::string initialState;
        std::set<std::string> finalStates;

        std::string line;
        while (std::getline(file, line)) {
            if (line.find("States:") == 0) {
                std::istringstream ss(line.substr(7));
                std::string state;
                while (std::getline(ss, state, ',')) {
                    state.erase(std::remove_if(state.begin(), state.end(), ::isspace), state.end());
                    states.insert(state);
                }
            } else if (line.find("Alphabet:") == 0) {
                std::istringstream ss(line.substr(9));
                char symbol;
                while (ss >> symbol) {
                    alphabet.insert(symbol);
                    ss.ignore(1); // Ignore commas
                }
            } else if (line.find("Transitions:") == 0) {
                while (std::getline(file, line) && line.find("Initial:") != 0 && line.find("Finals:") != 0) {
                    if (line.empty()) continue;

                    if (line.front() == '(' && line.back() == ')') {
                        line = line.substr(1, line.size() - 2);
                        std::replace(line.begin(), line.end(), ',', ' ');
                        std::istringstream ss(line);
                        std::string from, to;
                        char symbol;
                        ss >> from >> symbol >> to;
                        transitions.push_back({from, symbol, to});
                    } else {
                        std::cerr << "Error: Invalid transition format: " << line << std::endl;
                    }
                }
            }
            if (line.find("Initial:") == 0) {
                initialState = line.substr(8);
                initialState.erase(std::remove_if(initialState.begin(), initialState.end(), ::isspace), initialState.end());
            } else if (line.find("Finals:") == 0) {
                std::istringstream ss(line.substr(7));
                std::string state;
                while (std::getline(ss, state, ',')) {
                    state.erase(std::remove_if(state.begin(), state.end(), ::isspace), state.end());
                    finalStates.insert(state);
                }
            }
        }

        file.close();

        std::cout << "States: ";
        for (const auto &state : states) std::cout << state << " ";
        std::cout << "\nAlphabet: ";
        for (const auto &symbol : alphabet) std::cout << symbol << " ";
        std::cout << "\nTransitions:\n";
        for (const auto &trans : transitions) {
            std::cout << "(" << trans.from << ", " << trans.symbol << ", " << trans.to << ")\n";
        }
        std::cout << "Initial State: " << initialState << "\nFinal States: ";
        for (const auto &state : finalStates) std::cout << state << " ";
        std::cout << std::endl;
    } else {
        checkLexicalToken(input);
    }

    return 0;
}
