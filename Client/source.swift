
import Foundation
import CommandInterface
import RegexBuilder
import ArgumentParser
import Stratum


@main
struct Command: CommandInterface, ParsableCommand {
    
    mutating func run() throws {
        
        print("*hello*, **\("I", modifier: .foregroundColor(.red))** good")
    }
    
}
