//
//  CommandRead.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import Foundation


/// The interface for interacting with reading from stdin.
public struct CommandReadManager<Content> {
    
    private let prompt: String
    
    private let condition: ((_ content: Content) throws -> Bool)?
    
    private let promptModifier: ((_ content: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)?
    
    private var contentKey: CommandReadableContent<Content>.ContentKey
    
    
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
        CommandReadManager(prompt: self.prompt, condition: predicate, promptModifier: self.promptModifier, contentKey: self.contentKey)
    }
    
    /// The style modifier to the prompt.
    public func promptModifier(_ modifier: @escaping (_ content: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier) -> CommandReadManager {
        CommandReadManager(prompt: self.prompt, condition: self.condition, promptModifier: modifier, contentKey: self.contentKey)
    }
    
    private func __reportingError(error: some Error) {
        if let error = error as? ReadError {
            print("\u{1B}[31m" + error.reason + "\u{1B}[0m")
        } else {
            print("\u{1B}[31m" + (error as NSError).localizedDescription + "\u{1B}[0m")
        }
        Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
    }
    
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
        let modifier = CommandPrintManager.Modifier.default
        Swift.print(modifier.modify(prompt + terminator), terminator: "")
    }
    
    /// Gets the value. This is guaranteed, as it would keep asking the user for correct input.
    public func get() -> Content {
        var result: Content? = nil
        
        switch contentKey {
        case .boolean:
            __printPrompt(prompt: self.prompt + " [y/n]", terminator: ": ")
            
            while result == nil {
                guard let read = Swift.readLine() else {
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
                    continue
                }
                switch read.lowercased() {
                case "yes", "y":
                    result = true as? Content
                case "no", "n":
                    result = false as? Content
                default:
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
                    continue
                }
            }
            
        case .textFile:
            __printPrompt(prompt: prompt, terminator: ":\n")
            
            while result == nil {
                guard let read = Swift.readLine() else {
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
                    continue
                }
                let filePath = __normalize(filePath: read)
                
                do {
                    let text = try String(contentsOfFile: filePath)
                    let condition = try condition?(text as! Content)
                    guard condition ?? true else { throw ReadError(reason: "A unknown condition not met.") }
                    result = text as? Content
                } catch {
                    __reportingError(error: error)
                    continue
                }
            }
            
        case .filePath:
            __printPrompt(prompt: prompt, terminator: ":\n")
            
            while result == nil {
                guard let read = Swift.readLine() else {
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
                    continue
                }
                let filePath = __normalize(filePath: read)
                
                do {
                    let condition = try condition?(filePath as! Content)
                    guard condition ?? true else { throw ReadError(reason: "A unknown condition not met.") }
                    result = filePath as? Content
                } catch {
                    __reportingError(error: error)
                    continue
                }
            }
            
        case .string:
            __printPrompt(prompt: prompt, terminator: ":\n")
            
            while result == nil {
                guard let read = Swift.readLine() else {
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
                    continue
                }
                
                do {
                    let condition = try condition?(read as! Content)
                    guard condition ?? true else { throw ReadError(reason: "A unknown condition not met.") }
                    result = read as? Content
                } catch {
                    __reportingError(error: error)
                    continue
                }
            }
            
        case .double, .int:
            __printPrompt(prompt: prompt, terminator: ": ")
            
            while result == nil {
                guard let read = Swift.readLine() else {
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
                    continue
                }
                
                guard let value = (self.contentKey == .double ? Double(read) as? Content : Int(read) as? Content) else {
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mnot \(self.contentKey.rawValue), try again\u{1B}[0m: ", terminator: "")
                    continue
                }
                
                do {
                    let condition = try condition?(value)
                    guard condition ?? true else { throw ReadError(reason: "A unknown condition not met.") }
                    result = value
                } catch {
                    __reportingError(error: error)
                    continue
                }
            }
            
#if canImport(Support)
        case .finderItem:
            __printPrompt(prompt: prompt, terminator: ":\n")
            
            while result == nil {
                guard let read = Swift.readLine() else {
                    CommandOutputManager().bell()
                    Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
                    continue
                }
                let item = FinderItem(shellPath: read)
                
                do {
                    let condition = try condition?(item as! Content)
                    guard condition ?? true else { throw ReadError(reason: "A unknown condition not met.") }
                    result = item as? Content
                } catch {
                    __reportingError(error: error)
                    continue
                }
            }
#endif
        }
        
        return result!
    }
    
    internal init(prompt: String, condition: ((_ content: Content) throws -> Bool)? = nil, promptModifier: ((_ modifier: CommandPrintManager.Modifier) -> CommandPrintManager.Modifier)? = nil, contentKey: CommandReadableContent<Content>.ContentKey) {
        self.prompt = prompt
        self.condition = condition
        self.promptModifier = promptModifier
        self.contentKey = contentKey
    }
    
}


/// The error with a reason for the failure of reading.
public struct ReadError: LocalizedError {
    
    let reason: String
    
    var errorDescription: String {
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
