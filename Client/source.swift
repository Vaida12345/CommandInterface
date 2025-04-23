
import Foundation
import CommandInterface
import RegexBuilder
import ArgumentParser
import FinderItem


@main
struct Command: CommandInterface, AsyncParsableCommand {
    
    mutating func run() async throws {
        let manager = ShellManager()
        try manager.run(arguments: "geckodriver --port 4444")
        
        for try await line in manager.lines() {
            Swift.print(line)
        }
        
        manager.wait()
        
        Swift.print(manager.error() ?? "")
    }
    
}
