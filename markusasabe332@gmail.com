#include <iostream>
#include <fstream>
#include <string>
#include <unordered_map>

// Simple Gene Ontology term struct
struct GOTerm {
    std::string id;
    std::string name;
    std::string namespace_;
    std::string definition;
};

int main() {
    // Example: Load GO terms from OBO file
    std::ifstream goFile("go.obo");
    if (!goFile.is_open()) {
        std::cerr << "Error opening GO file." << std::endl;
        return 1;
    }

    std::unordered_map<std::string, GOTerm> goTerms;
    std::string line;
    GOTerm currentTerm;

    while (std::getline(goFile, line)) {
        if (line.find("[Term]") != std::string::npos) {
            // Start new term
            currentTerm = GOTerm();
        } else if (line.find("id:") != std::string::npos) {
            currentTerm.id = line.substr(4);
        } else if (line.find("name:") != std::string::npos) {
            currentTerm.name = line.substr(6);
        } else if (line.find("namespace:") != std::string::npos) {
            currentTerm.namespace_ = line.substr(11);
        } else if (line.find("def:") != std::string::npos) {
            currentTerm.definition = line.substr(5);
        } else if (line.empty()) {
            // End of term, store it
            if (!currentTerm.id.empty()) {
                goTerms[currentTerm.id] = currentTerm;
            }
        }
    }
    goFile.close();

    // Example usage: Print GO terms
    for (const auto& term : goTerms) {
        std::cout << "ID: " << term.second.id << std::endl;
        std::cout << "Name: " << term.second.name << std::endl;
        std::cout << "Namespace: " << term.second.namespace_ << std::endl;
        std::cout << "Definition: " << term.second.definition << std::endl;
        std::cout << std::endl;
    }

    return 0;
}
