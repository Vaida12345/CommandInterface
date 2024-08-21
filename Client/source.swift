
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
            let input = read(.options("!2345").stopSequence([]), prompt: "read: ")
            print(">>>> \(input)")
            
//            let input = self.read(.bool.default(true), prompt: "read: ")
//            print(">>>> \(input)")
            
        }
    }
    
}


enum Model: String, CaseIterable {
     case a
}
