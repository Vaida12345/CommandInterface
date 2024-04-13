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
    
    private let prompt: String
    
    private let condition: ((_ content: Content) throws -> Bool)?
    
    private let promptModifier: ((_ content: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)?
    
    private var contentKey: CommandReadableContent<Content>.ContentKey
    
    private var defaultValue: Content?
    
    
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
        CommandReadManager(prompt: self.prompt, condition: predicate, promptModifier: self.promptModifier, defaultValue: self.defaultValue, contentKey: self.contentKey)
    }
    
    /// The style modifier to the prompt.
    public func promptModifier(_ modifier: @escaping (_ content: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier) -> CommandReadManager {
        CommandReadManager(prompt: self.prompt, condition: self.condition, promptModifier: modifier, defaultValue: self.defaultValue, contentKey: self.contentKey)
    }
    
    /// Sets the default value. If no input was received, the default value would be used.
    public func `default`(value: Content) -> CommandReadManager {
        CommandReadManager(prompt: self.prompt, condition: self.condition, promptModifier: self.promptModifier, defaultValue: value, contentKey: self.contentKey)
    }
    
    
    // MARK: - Internal
    
    private func __normalize(filePath: String) -> String {
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
    
    private func __printPrompt(prompt: String, terminator: String) {
        let modifier = (promptModifier ?? { $0 })(.default)
        Swift.print(modifier.modify(prompt + terminator), terminator: "")
    }
    
    private func __getLoop(prompt: String, terminator: String, printPrompt: Bool = true, body: @escaping (_ read: String) throws -> Content?) -> Content {
        if printPrompt {
            __printPrompt(prompt: prompt, terminator: terminator)
        }
        
        guard let read = Swift.readLine() else {
            CommandOutputManager().bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            return __getLoop(prompt: prompt, terminator: terminator, printPrompt: false, body: body)
        }
        
        if let defaultValue, read.isEmpty {
            
            let defaultValueModifier = CommandPrintManager.Modifier.default.foregroundColor(.secondary)
            Swift.print(defaultValueModifier.modify("using default value: \(defaultValue)"))
            
            return defaultValue
        }
        
        do {
            guard let value = try body(read) else { throw ReadError(reason: "Invalid Input") }
            
            let condition = try condition?(value)
            guard condition ?? true else { throw ReadError(reason: "Condition not met.") }
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
        switch contentKey {
        case .boolean:
            return __getLoop(prompt: self.prompt + " [y/n]", terminator: ": ") { read in
                switch read.lowercased() {
                case "yes", "y":
                    return true as? Content
                case "no", "n":
                    return false as? Content
                default:
                    return nil
                }
            }
            
        case .textFile:
            return __getLoop(prompt: prompt, terminator: ":\n") { read in
                let filePath = __normalize(filePath: read)
                return try String(contentsOfFile: filePath) as? Content
            }
            
        case .filePath:
            return __getLoop(prompt: prompt, terminator: ":\n") { read in
                __normalize(filePath: read) as? Content
            }
            
        case .string:
            return __getLoop(prompt: prompt, terminator: ": ") { read in
                read as? Content
            }
            
        case .double, .int:
            return __getLoop(prompt: prompt, terminator: ": ") { read in
                self.contentKey == .double ? Double(read) as? Content : Int(read) as? Content
            }
            
        case .finderItem:
            return __getLoop(prompt: prompt, terminator: ":\n") { read in
                FinderItem(at: read) as? Content
            }
        }
    }
    
    internal init(prompt: String, condition: ((_ content: Content) throws -> Bool)? = nil, promptModifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil, defaultValue: Content? = nil, contentKey: CommandReadableContent<Content>.ContentKey) {
        self.prompt = prompt
        self.condition = condition
        self.promptModifier = promptModifier
        self.contentKey = contentKey
        self.defaultValue = defaultValue
    }
    
}


/// The error with a reason for the failure of reading.
public struct ReadError: LocalizedError {
    
    fileprivate let reason: String
    
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
