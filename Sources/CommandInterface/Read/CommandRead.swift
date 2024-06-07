//
//  CommandRead.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation
import Stratum


/// The interface for interacting with reading from stdin.
public struct CommandReadManager<Content> {
    
    internal let prompt: String
    
    internal let condition: ((_ content: Content) throws -> Bool)?
    
    internal let promptModifier: ((_ content: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)?
    
    internal var contentType: CommandReadableContent<Content>
    
    internal var defaultValue: Content?
    
    
    // MARK: - Modifiers
    
    /// Sets the condition that must meet for the read content considered succeed.
    ///
    /// In this example, the given text file must contain "Hello".
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file")
    ///     .condition { content in
    ///         content.contains("Hello")
    ///     }
    ///     .get()
    /// ```
    ///
    /// You can also provide the reason for failure using `throw`.
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file")
    ///     .condition { content in
    ///         guard content.contains("Hello") else {
    ///             throw ReadError(reason: "Source not contain \"Hello\"")
    ///             return true
    ///         }
    ///     }
    ///     .get()
    /// ```
    public func condition(_ predicate: @escaping (_ content: Content) throws -> Bool) -> CommandReadManager {
        CommandReadManager(prompt: self.prompt, condition: predicate, promptModifier: self.promptModifier, defaultValue: self.defaultValue, contentType: self.contentType)
    }
    
    /// The style modifier to the prompt.
    public func promptModifier(_ modifier: @escaping (_ content: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier) -> CommandReadManager {
        CommandReadManager(prompt: self.prompt, condition: self.condition, promptModifier: modifier, defaultValue: self.defaultValue, contentType: self.contentType)
    }
    
    /// Sets the default value. If no input was received, the default value would be used.
    public func `default`(value: Content) -> CommandReadManager {
        CommandReadManager(prompt: self.prompt, condition: self.condition, promptModifier: self.promptModifier, defaultValue: value, contentType: self.contentType)
    }
    
    
    // MARK: - Internal
    
    
    
    internal func __printPrompt(prompt: String, terminator: String) {
        let modifier = (promptModifier ?? { $0 })(.default)
        Swift.print(modifier.modify(prompt + terminator), terminator: "")
    }
    
    private func __getLoop(prompt: String, terminator: String, printPrompt: Bool = true, body: @escaping (_ read: String) throws -> Content?) -> Content {
        if printPrompt {
            __printPrompt(prompt: prompt, terminator: terminator)
        }
        
        guard let read = Swift.readLine() else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            return __getLoop(prompt: prompt, terminator: terminator, printPrompt: false, body: body)
        }
        
        if let defaultValue, read.isEmpty {
            
            let defaultValueModifier = CommandPrintManager.Modifier.default.foregroundColor(.secondary)
            Swift.print(defaultValueModifier.modify("using default value: \(defaultValue)"))
            
            return defaultValue
        }
        
        do {
            if let condition = contentType.condition {
                guard try condition(read) else { throw ReadError(reason: "Invalid Input.") }
            }
            
            guard let value = try body(read) else { throw ReadError(reason: "Invalid Input") }
            
            let condition = try condition?(value)
            guard condition ?? true else { throw ReadError(reason: "Invalid Input.") }
            
            return value
        } catch {
            if let error = error as? ReadError {
                print("\u{1B}[31m" + error.reason + "\u{1B}[0m")
            } else {
                print("\u{1B}[31m" + (error as NSError).localizedDescription + "\u{1B}[0m")
            }
            Swift.print("\u{1B}[31mTry again: \u{1B}[0m", terminator: "")
            
            return __getLoop(prompt: prompt, terminator: terminator, printPrompt: false, body: body)
        }
    }
    
    /// Gets the value. This is guaranteed, as it would keep asking the user for correct input.
    public func get() -> Content {
        if let getLoop = contentType.overrideGetLoop {
            getLoop(self, contentType)
        } else {
            __getLoop(prompt: self.prompt, terminator: self.contentType.terminator, body: self.contentType.initializer)
        }
    }
    
    internal init(prompt: String, condition: ((_ content: Content) throws -> Bool)? = nil, promptModifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil, defaultValue: Content? = nil, contentType: CommandReadableContent<Content>) {
        self.prompt = prompt
        self.condition = condition
        self.promptModifier = promptModifier
        self.contentType = contentType
        self.defaultValue = defaultValue
    }
    
}


/// The error with a reason for the failure of reading.
public struct ReadError: LocalizedError {
    
    let reason: String
    
    public var errorDescription: String? {
        self.reason
    }
    
    /// Initialize with a reason.
    ///
    /// - Parameters:
    ///   - reason: The reason why an error occurred.
    public init(reason: String) {
        self.reason = reason
    }
    
}


extension CommandReadManager: CustomStringConvertible where Content: CustomStringConvertible {
    
    public var description: String {
        self.get().description
    }
    
}


func __normalize(filePath: String) -> String {
    (filePath.hasSuffix(" ") ? String(filePath.dropLast()) : filePath)
        .replacingOccurrences(of: "\\ ", with: " ")
        .replacingOccurrences(of: "\\(", with: "(")
        .replacingOccurrences(of: "\\)", with: ")")
        .replacingOccurrences(of: "\\[", with: "[")
        .replacingOccurrences(of: "\\]", with: "]")
        .replacingOccurrences(of: "\\{", with: "{")
        .replacingOccurrences(of: "\\}", with: "}")
        .replacingOccurrences(of: "\\`", with: "`")
        .replacingOccurrences(of: "\\~", with: "~")
        .replacingOccurrences(of: "\\!", with: "!")
        .replacingOccurrences(of: "\\@", with: "@")
        .replacingOccurrences(of: "\\#", with: "#")
        .replacingOccurrences(of: "\\$", with: "$")
        .replacingOccurrences(of: "\\%", with: "%")
        .replacingOccurrences(of: "\\&", with: "&")
        .replacingOccurrences(of: "\\*", with: "*")
        .replacingOccurrences(of: "\\=", with: "=")
        .replacingOccurrences(of: "\\|", with: "|")
        .replacingOccurrences(of: "\\;", with: ";")
        .replacingOccurrences(of: "\\\"", with: "\"")
        .replacingOccurrences(of: "\\\'", with: "\'")
        .replacingOccurrences(of: "\\<", with: "<")
        .replacingOccurrences(of: "\\>", with: ">")
        .replacingOccurrences(of: "\\,", with: ",")
        .replacingOccurrences(of: "\\?", with: "?")
        .replacingOccurrences(of: "\\\\", with: "\\")
}
