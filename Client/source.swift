
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
//            let input = self.read(.options(["hello", "you"]), prompt: "read: ")
//            let input = self.read(.bool.default(true), prompt: "read: ")
//            print(">>>> \(input)")
            
//            let string = Terminal.defaultInterface.read(.string.default("abc"), prompt: "")
            
            
        }
    }
    
}


enum Model: String, CaseIterable {
     case a
}
