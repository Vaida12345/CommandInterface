//
//  CommandInterface.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation
import ArgumentParser
import OSLog


/// The protocol whose conforming types serve as entry points.
///
/// To use `read`, always set
/// ```swift
/// var __raw = __setRawMode(); defer { __resetTerminal(originalTerm: &__raw) }
/// ```
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
    @available(*, deprecated, renamed: "print(_:terminator:modifiers:)", message: "Use the inline modifier in stead.")
    @inlinable
    func print(_ item: CommandPrintManager.Interpolation, terminator: String = "\n", modifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil) {
        self.print(item, terminator: terminator, modifiers: modifier?(.default) ?? .default)
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    @inlinable
    func print(_ item: CommandPrintManager.Interpolation, terminator: String = "\n") {
        self.print(item, terminator: terminator, modifiers: .default)
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    func print(_ item: CommandPrintManager.Interpolation, terminator: String = "\n", modifiers: CommandPrintManager.Modifier...) {
        let contents = if !modifiers.isEmpty {
            modifiers.reduce(into: CommandPrintManager.Modifier.default, { $0.formUnion($1) }).modify(item.description)
        } else {
            item.description
        }
        
        do {
            let parsedContent = try AttributedString(markdown: contents, options: .init(failurePolicy: .returnPartiallyParsedIfPossible))
            var interpolation = CommandPrintManager.Interpolation(literalCapacity: 0, interpolationCount: 1)
            interpolation.appendInterpolation(parsedContent)
            
            Swift.print(interpolation.description, terminator: terminator)
        } catch {
            let logger = Logger(subsystem: "CommandInterface", category: "Markdown Parsing")
            logger.error("\(#function) cannot parse markdown: \"\(contents)\". It will not be treated as markdown.")
            Swift.print(contents, terminator: terminator)
        }
        
        fflush(stdout)
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    @inlinable
    @available(*, deprecated, renamed: "print(_:terminator:modifiers:)", message: "Use the inline modifier in stead.")
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n", modifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil) {
        self.print(items, separator: separator, terminator: terminator, modifiers: modifier?(.default) ?? .default)
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    @inlinable
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        self.print(items, separator: separator, terminator: terminator, modifiers: .default)
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    @inlinable
    func print(_ items: Any..., separator: String = " ", terminator: String = "\n", modifiers: CommandPrintManager.Modifier...) {
        self.print(items, separator: separator, terminator: terminator, modifiers: modifiers.reduce(into: CommandPrintManager.Modifier.default, { $0.formUnion($1) }))
    }
    
    /// Prints the target value.
    ///
    /// The terminator remains unformatted.
    @inlinable
    func print(_ items: [Any], separator: String = " ", terminator: String = "\n", modifiers: CommandPrintManager.Modifier...) {
        var interpolation = CommandPrintManager.Interpolation(literalCapacity: 0, interpolationCount: items.count)
        for (index, item) in items.enumerated() {
            interpolation.appendInterpolation(item)
            
            if index != items.count - 1 {
                interpolation.appendLiteral(separator)
            }
        }
        
        self.print(interpolation, terminator: terminator, modifiers: modifiers.reduce(into: CommandPrintManager.Modifier.default, { $0.formUnion($1) }))
    }
    
    /// Reads a value from stdin.
    ///
    /// Use this the way you use `SwiftUI` views and modifiers. for example,
    ///
    /// ```swift
    /// let value = read(.double, prompt: "Enter a value", 
    ///                  default: 3.14) { $0 > 0 }
    /// ```
    ///
    /// ## Condition Modifier
    /// Sets the condition that must meet for the read content considered succeed.
    ///
    /// In this example, the given text file must contain "Hello".
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file") { content in
    ///     content.contains("Hello")
    /// }
    /// ```
    ///
    /// You can also provide the reason for failure using `throw`.
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file") { content in
    ///     guard content.contains("Hello") else {
    ///         throw ReadError(reason: "Source not contain \"Hello\"")
    ///         return true
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - contentType: The content type for reading. See ``CommandReadableContent``.
    ///   - prompt: The prompt shown to the user.
    ///   - condition: The condition that will be matched against.
    func read<Content>(_ contentType: CommandReadableContent<Content>, prompt: CommandPrintManager.Interpolation,
                       condition: ((_ content: Content) throws -> Bool)? = nil) -> Content {
        CommandReadManager(prompt: prompt.description, contentType: contentType, condition: contentType.condition ?? condition).get()
    }
    
    
}

