
import Foundation
import CommandInterface
import RegexBuilder
import ArgumentParser
import FinderItem


@main
struct Command: CommandInterface, ParsableCommand {
    
    mutating func run() throws {
        Terminal.setRawMode()
        
        let hello = "Hello!"
        print("\(hello, modifier: .italic.underline().foregroundColor(.blue))")
    }
    
}


enum Model: String, CaseIterable {
     case a
}
