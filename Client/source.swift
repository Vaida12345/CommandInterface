
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
            let input = self.read(.string.default("yes"), prompt: "")
            print(">>>> \(input)")
        }
    }
    
}


enum Model: String, CaseIterable {
     case a
}
