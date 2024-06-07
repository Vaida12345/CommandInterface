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
public protocol CommandInterface: ParsableCommand {
    
    
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
    }
    
    /// Reads a value from stdin.
    ///
    /// Use this the way you use `SwiftUI` views and modifiers. for example,
    ///
    /// ```swift
    /// let value = read(.double, prompt: "Enter a value")
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
    func read<Content>(_ contentType: CommandReadableContent<Content>, prompt: CommandPrintManager.Interpolation, terminator: String? = nil) -> CommandReadManager<Content> {
        CommandReadManager(prompt: prompt.description, contentType: contentType)
    }
    
    
}

