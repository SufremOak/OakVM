#include <iostream>
#include <string>
#include <vector>
#include <unistd.h>
#include <sys/wait.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <filesystem>
#include <termios.h>
#include <cstdlib>

#define RESET   "\033[0m"
#define RED     "\033[31m"
#define GREEN   "\033[32m"
#define BLUE    "\033[34m"
#define YELLOW  "\033[33m"

class OakShell {
private:
    std::string prompt;
    std::vector<std::string> history;
    bool running;

    std::vector<std::string> splitCommand(const std::string& cmd) {
        std::vector<std::string> tokens;
        std::string token;
        bool inQuotes = false;

        for (char c : cmd) {
            if (c == '"') {
                inQuotes = !inQuotes;
            } else if (c == ' ' && !inQuotes) {
                if (!token.empty()) {
                    tokens.push_back(token);
                    token.clear();
                }
            } else {
                token += c;
            }
        }
        if (!token.empty()) {
            tokens.push_back(token);
        }
        return tokens;
    }

    void executeCommand(const std::string& cmd) {
        std::vector<std::string> args = splitCommand(cmd);
        if (args.empty()) return;

        if (args[0] == "exit") {
            running = false;
            return;
        }

        if (args[0] == "cd") {
            if (args.size() < 2) {
                chdir(getenv("HOME"));
            } else {
                if (chdir(args[1].c_str()) != 0) {
                    std::cerr << RED << "cd: No such directory: " << args[1] << RESET << std::endl;
                }
            }
            return;
        }

        pid_t pid = fork();
        if (pid == 0) {
            // Child process
            std::vector<char*> c_args;
            for (const auto& arg : args) {
                c_args.push_back(const_cast<char*>(arg.c_str()));
            }
            c_args.push_back(nullptr);

            execvp(c_args[0], c_args.data());
            std::cerr << RED << "Command not found: " << args[0] << RESET << std::endl;
            exit(1);
        } else if (pid > 0) {
            // Parent process
            int status;
            waitpid(pid, &status, 0);
        }
    }

public:
    OakShell() : prompt(GREEN "oaksh> " RESET), running(true) {
        using_history();
    }

    void run() {
        char* input;
        while (running && (input = readline(prompt.c_str()))) {
            std::string cmd(input);
            if (!cmd.empty()) {
                add_history(input);
                history.push_back(cmd);
                executeCommand(cmd);
            }
            free(input);
        }
    }
};

int main() {
    OakShell shell;
    shell.run();
    return 0;
}
