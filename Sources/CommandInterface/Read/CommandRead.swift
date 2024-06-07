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
    
    internal var contentType: CommandReadableContent<Content>
    
    internal var defaultValue: Content?
    
    internal var terminator: String? = nil
    
    
    // MARK: - Internal
    
    
    
    internal func __printPrompt(prompt: String, terminator: String) {
        Swift.print(prompt, terminator: self.terminator ?? terminator)
    }
    
    private func __readline(printDefault: Bool) -> String? {
        var storage = StandardInputStorage()
        
        if let defaultValue, printDefault {
            let len = storage.insertAtCursor(formatted: "\(defaultValue, modifier: .dim)")
            storage.move(to: .left, length: len)
        }
        
        while let next = __consumeNext() {
            switch next {
            case .newline:
                return String(storage.buffer)
                
            case .tab:
                if let defaultValue, printDefault,
                   "\(defaultValue)".hasPrefix(String(storage.buffer)),
                   storage.cursor == storage.buffer.count || storage.buffer.isEmpty {
                    var value = "\(defaultValue)"
                    if !storage.buffer.isEmpty {
                        for _ in 1...storage.cursor {
                            value.removeFirst()
                        }
                    }
                    
                    let len = storage.insertAtCursor(value)
                }
                
            case .char(let char):
                if let defaultValue, printDefault,
                   storage.cursor < storage.buffer.count,
                   storage.buffer[storage.cursor] != char {
                    storage.eraseFromCursorToEndOfLine()
                }
                storage.write(char)
                
            default:
                storage.handle(next)
            }
        }
        
        return nil
    }
    
    private func __getLoop(prompt: String, terminator: String, printPrompt: Bool = true, body: @escaping (_ read: String) throws -> Content?) -> Content {
        if printPrompt {
            __printPrompt(prompt: prompt, terminator: terminator)
        }
        
        guard let read = __readline(printDefault: printPrompt && !(self.terminator ?? terminator).contains("\n")) else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            return __getLoop(prompt: prompt, terminator: terminator, printPrompt: false, body: body)
        }
        
        if let defaultValue, read.isEmpty {
            return defaultValue
        }
        
        do {
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
            return getLoop(self, contentType)
        } else {
            var __raw = __setRawMode(); defer { __resetTerminal(originalTerm: &__raw) }
            
            return __getLoop(prompt: self.prompt, terminator: self.contentType.terminator, body: self.contentType.initializer)
        }
    }
    
    
    internal init(prompt: String, contentType: CommandReadableContent<Content>, defaultValue: Content? = nil, terminator: String? = nil,
                  condition: ((_ content: Content) throws -> Bool)? = nil) {
        self.prompt = prompt
        self.condition = condition
        self.contentType = contentType
        self.defaultValue = defaultValue
        self.terminator = terminator
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
