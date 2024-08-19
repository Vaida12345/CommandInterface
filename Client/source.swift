
import Foundation
import CommandInterface
import RegexBuilder
import ArgumentParser
import Stratum


@main
struct Command: CommandInterface, ParsableCommand {
    
    mutating func run() throws {
        Terminal.setRawMode()
        
        while true {
            let input = self.read(.options(["hello", "you"]), prompt: "read: ")
            print(">>>> \(input)")
        }
    }
    
}


enum Model: String, CaseIterable {
     case a
}
