//
//  CommandInterface.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation
import ArgumentParser


/// The protocol whose conforming types serve as entry points.
public protocol CommandInterface {
    
    
}


public extension CommandInterface {
    
    /// Link to the interface for interacting with printing to stdout.
    ///
    /// The ``print(_:separator:terminator:modifier:)`` is recommended.
    var print: CommandPrintManager {
        CommandPrintManager()
    }
    
    /// Link to the interface for interacting with stdout.
    @inlinable
    var terminal: Terminal.Type {
        Terminal.self
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    func print(_ item: CommandPrintManager.Interpolation, terminator: String = "\n", modifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil) {
        if let modifier = modifier?(CommandPrintManager.Modifier.default) {
            Swift.print(modifier.modify(item.description), terminator: terminator)
        } else {
            Swift.print(item.description, terminator: terminator)
        }
        fflush(stdout)
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n", modifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil) {
        var result = ""
        Swift.print(items, separator: separator, terminator: "", to: &result)
        if let modifier = modifier?(CommandPrintManager.Modifier.default) {
            Swift.print(modifier.modify(result), terminator: terminator)
        } else {
            Swift.print(result, terminator: terminator)
        }
        fflush(stdout)
    }
    
    /// Reads a value from stdin.
    ///
    /// Use this the way you use `SwiftUI` views and modifiers. for example,
    ///
    /// ```swift
    /// let value = read(.double, prompt: "Enter a value", 
    ///                  default: 3.14) { $0 < 0 }
    /// ```
    ///
    /// ## Condition Modifier
    /// Sets the condition that must meet for the read content considered succeed.
    ///
    /// In this example, the given text file must contain "Hello".
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file") { content in
    ///         content.contains("Hello")
    ///     }
    /// ```
    ///
    /// You can also provide the reason for failure using `throw`.
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file") { content in
    ///         guard content.contains("Hello") else {
    ///             throw ReadError(reason: "Source not contain \"Hello\"")
    ///             return true
    ///         }
    ///     }
    /// ```
    ///
    /// - Parameters:
    ///   - contentType: The content type for reading. See ``CommandReadableContent``.
    ///   - prompt: The prompt shown to the user.
    ///   - default: The default value
    ///   - terminator: The terminator, which will not be formatted
    ///   - condition: The condition that will be matched against.
    func read<Content>(_ contentType: CommandReadableContent<Content>, prompt: CommandPrintManager.Interpolation,
                       default: Content? = nil, terminator: String? = nil,
                       condition: ((_ content: Content) throws -> Bool)? = nil) -> Content {
        CommandReadManager(prompt: prompt.description, contentType: contentType, defaultValue: `default`, terminator: terminator, condition: contentType.condition ?? condition).get()
    }
    
    
}

