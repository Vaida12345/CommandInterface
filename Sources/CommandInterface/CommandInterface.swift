//
//  CommandInterface.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import CoreGraphics


/// The protocol whose conforming types serve as entry points.
public protocol CommandInterface {
    
    /// The entry point.
    func run() async throws
    
    /// The initializer of your structure.
    ///
    /// Typically this initializer does not require implementation, as Swift would do it for you.
    init()
    
}


public extension CommandInterface {
    
#if canImport(ArgumentParser)
    // Already defined in ArgumentParser.
#else
    /// The implementation of entry point.
    static func main() async {
        do {
            try await Self().run()
        } catch {
            fatalError("Error: \(error)")
        }
    }
#endif
    
    
    /// Link to the interface for interacting with printing to stdout.
    ///
    /// The ``print(_:separator:terminator:modifier:)`` is recommended.
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
            Swift.print(modifier.modify(body), terminator: terminator)
        } else {
            Swift.print(body, terminator: terminator)
        }
    }
    
    /// Reads a value from stdin.
    ///
    /// Use this the way you use `SwiftUI` views and modifiers. for example,
    ///
    /// ```swift
    /// let value = self.read(.double, prompt: "Enter a value")
    ///     .default(value: 3.14)
    ///     .condition { $0 < 0 }
    ///     .get()
    /// ```
    ///
    /// For a list of modifiers, see ``CommandReadManager``.
    ///
    /// - Important: Use .``CommandReadManager/get()`` to obtain the read value.
    ///
    /// - Parameters:
    ///   - contentType: The content type for reading. See ``CommandReadableContent``.
    ///   - prompt: The prompt shown to the user.
    func read<Content>(_ contentType: CommandReadableContent<Content>, prompt: String) -> CommandReadManager<Content> {
        CommandReadManager(prompt: prompt, contentKey: contentType.contentKey)
    }
    
}
