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
    var output: CommandOutputManager {
        CommandOutputManager()
    }
    
    /// Prints the target value.
    func print(_ item: CommandPrintManager.Interpolation, separator: String = " ", terminator: String = "\n", modifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil) {
        if let modifier = modifier?(CommandPrintManager.Modifier.default) {
            Swift.print(modifier.modify(item.description), terminator: terminator)
        } else {
            Swift.print(item.description, terminator: terminator)
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
    func read<Content>(_ contentType: CommandReadableContent<Content>, prompt: String) -> CommandReadManager<Content> {
        CommandReadManager(prompt: prompt, contentKey: contentType.contentKey)
    }
    
}
