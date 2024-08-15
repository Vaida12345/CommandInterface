
import Foundation
import CommandInterface
import RegexBuilder
import ArgumentParser
import Stratum


@main
struct Command: CommandInterface, ParsableCommand {
    
    mutating func run() throws {
        var string = AttributedString("12345")
        string.foregroundColor = .blue
        string.inlinePresentationIntent = .stronglyEmphasized
        
        print("The sum is \(string).")
    }
    
}
