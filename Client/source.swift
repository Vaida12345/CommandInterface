
import Foundation
import CommandInterface
import RegexBuilder
import ArgumentParser
import Stratum


@main
struct Command: CommandInterface, ParsableCommand {
    
    mutating func run() throws {
        var string = AttributedString("12345")
        
        print("The sum is \(string, modifiers: .foregroundColor(.rgb(100, 100, 10)), .blinking).")
    }
    
}
