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
/// Terminal.setRawMode()
/// ```
///
/// To declare the main entrance, please declare the command as `ParsableCommand` or `AsyncParsableCommand`.
///
/// ## Topics
///
/// ### IO
/// - ``read(_:prompt:condition:)``
/// - ``print(_:terminator:)``
///
/// ### Controls
/// - ``terminal``
public protocol CommandInterface {
    
    
}


struct DefaultInterface: CommandInterface {
    
    static var `default`: DefaultInterface {
        DefaultInterface()
    }
    
}

public extension CommandInterface {
    
    /// Link to the interface for interacting with stdout.
    @inlinable
    var terminal: Terminal.Type {
        Terminal.self
    }
    
    /// Prints the target value.
    ///
    /// Using interpolation, you could control the style for each entry.
    ///
    /// In this example, it would print \"*Hello* **!**\".
    /// ```swift
    /// print("\("Hello", modifier: .italic) \("!", modifier: .bold)")
    /// ```
    ///
    /// With the support for `AttributedString`, you could add them directly to interpolation.
    /// ```swift
    /// var string = AttributedString("12345")
    /// string.foregroundColor = .blue
    /// string.inlinePresentationIntent = .stronglyEmphasized
    ///
    /// print("The sum is \(string).")
    /// ```
    func print(_ item: CommandPrintManager.Interpolation, terminator: String = "\n") {
        Terminal.print(item, terminator: terminator)
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
    ///     }
    ///     return true
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - contentType: The content type for reading. See ``CommandReadable``.
    ///   - prompt: The prompt shown to the user.
    ///   - condition: The condition that will be matched against.
    func read<T>(
        _ contentType: T,
        prompt: CommandPrintManager.Interpolation,
        condition: ((_ content: T.Content) throws -> Bool)? = nil
    ) -> T.Content where T: CommandReadable {
        Terminal.read(contentType, prompt: prompt, condition: condition)
    }
    
    
}

