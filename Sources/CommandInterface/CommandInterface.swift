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
    func read<Content>(_ contentType: CommandReadableContent<Content>, prompt: CommandPrintManager.Interpolation) -> CommandReadManager<Content> {
        CommandReadManager(prompt: prompt.description, contentType: contentType)
    }
    
    
    
}


public enum NextChar: Equatable {
    case up
    case down
    case right
    case left
    case tab
    case newline
    case backspace
    case string(String)
}


/// Consume and returns next char.
///
/// To use this, you must define the following in the function in which this is called.
///
/// - Note: You need to `fflush` to push output.
///
/// ```swift
/// var __raw = __setRawMode()
/// defer {
///     __resetTerminal(originalTerm: &__raw)
/// }
/// ```
func __consumeNext() -> NextChar? {
    
    let inputHandle = FileHandle.standardInput
    guard let next = try? inputHandle.read(upToCount: 1), let char = String(data: next, encoding: .utf8) else { return nil }
    
    switch char {
    case "\u{1B}" :
        if let next = try? inputHandle.read(upToCount: 2), let strings = String(data: next, encoding: .utf8) {
            let char = [Character](strings)
            if char.count == 2, char[0] == "[" {
                switch char[1] {
                case "A":
                    return .up
                case "B":
                    return .down
                case "C":
                    return .right
                case "D":
                    return .left
                default:
                    return .string("\u{1B}\(char)")
                }
            } else {
                return .string("\u{1B}\(char)")
            }
        } else {
            return .string("\u{1B}")
        }
        
    case "\t":
        return .tab
        
    case "\n":
        return .newline
        
    case "\u{7F}":
        return .backspace
        
    default:
        return .string(char)
    }
}


// Function to set the terminal to raw mode
func __setRawMode() -> termios {
    fflush(stdout)
    
    var originalTerm = termios()
    var rawTerm = termios()
    
    // Get the current terminal settings
    tcgetattr(STDIN_FILENO, &originalTerm)
    rawTerm = originalTerm
    
    // Set the terminal to raw mode
    rawTerm.c_lflag &= ~(UInt(ICANON | ECHO))
    rawTerm.c_cc.0 = 1 // VMIN
    rawTerm.c_cc.1 = 0 // VTIME
    
    tcsetattr(STDIN_FILENO, TCSANOW, &rawTerm)
    
    return originalTerm
}

// Function to reset the terminal to its original settings
func __resetTerminal(originalTerm: inout termios) {
    tcsetattr(STDIN_FILENO, TCSANOW, &originalTerm)
}
