//
//  CommandInterface.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import CHelpers
import CoreGraphics


/// The protocol whose conforming types serve as entry points.
public protocol CommandInterface {
    
    /// The entry point.
    func main() async throws
    
    /// The initializer of your structure.
    ///
    /// Typically this initializer does not require implementation, as Swift would do it for you.
    init()
    
}


public extension CommandInterface {
    
    /// The implementation of entry point.
    static func main() async {
        do {
            try await Self().main()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
    
    /// Link to the interface for interacting with printing to stdout.
    ///
    /// The ``CommandPrintManager/callAsFunction(_:separator:terminator:modifier:)`` is recommended.
    var print: CommandPrintManager {
        CommandPrintManager()
    }
    
    /// Link to the interface for interacting with stdout.
    var output: CommandOutputManager {
        CommandOutputManager()
    }
    
    /// Prints the target value.
    ///
    /// - Note: The terminator is not styled using `modifier`.
    ///
    /// - Parameters:
    ///   - items: Zero or more items to print.
    ///   - separator: A string to print between each item. The default is a single space (" ").
    ///   - terminator: The string to print after all items have been printed. The default is a newline ("\n").
    ///   - modifier: The style modifier to `items`.
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n", modifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil) {
        let body = items.map(String.init(describing:)).joined(separator: separator)
        
        if let modifier = modifier?(CommandPrintManager.Modifier.default) {
            let escapers = modifier.escaper
            Swift.print("\u{1B}[\(escapers)m" + body + "\u{1B}[0m", terminator: terminator)
        } else {
            Swift.print(body, terminator: terminator)
        }
    }
    
    func read<Content>(_ contentType: CommandReadableContent<Content>, prompt: String) -> CommandReadManager<Content> {
        CommandReadManager(prompt: prompt, contentKey: contentType.contentKey)
    }
    
}


public extension CommandInterface {
    
    func presentProgress(progress: Double) {
        let size = __getTerminalSize()
        let total = Int(size.ws_col - 2)
        let completed = Int(Double(total) * progress)
        
        let value = "[" + String(repeating: "=", count: completed) + String(repeating: " ", count: total - completed) + "]"
        print(value, terminator: "\r")
    }
    
}
