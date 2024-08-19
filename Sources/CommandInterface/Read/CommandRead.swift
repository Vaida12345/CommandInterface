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
    
    internal let prompt: CommandPrintManager.Interpolation
    
    internal let condition: ((_ content: Content) throws -> Bool)?
    
    internal var contentType: CommandReadableContent<Content>
    
    
    // MARK: - Internal
    
    
    
    internal func __printPrompt() {
        DefaultInterface.default.print(self.prompt, terminator: "")
        fflush(stdout)
    }
    
    func __readline(printDefault: Bool) -> StandardInputStorage? {
        var storage = StandardInputStorage()
        
        var defaultValueLiteral: String? {
            if let defaultValue = contentType.defaultValue, printDefault {
                return contentType.formatter?(defaultValue) ?? "\(defaultValue)"
            }
            return nil
        }
        
        if let defaultValue = defaultValueLiteral {
            let len = storage.insertAtCursor(formatted: "\(defaultValue, modifier: .dim)")
            storage.move(to: .left, length: len)
        }
        
        while let next = NextChar.consumeNext() {
            switch next {
            case .newline:
                Swift.print("\n", terminator: "")
                fflush(stdout)
                return storage
                
//            case .tab:
//                if let defaultValue = defaultValueLiteral,
//                   defaultValue.hasPrefix(String(storage.buffer)),
//                   storage.cursor == storage.buffer.count || storage.buffer.isEmpty {
//                    var value = defaultValue
//                    if !storage.buffer.isEmpty {
//                        for _ in 1...storage.cursor {
//                            value.removeFirst()
//                        }
//                    }
//                    storage.insertAtCursor(value)
//                }
//                
//            case .char(let char):
//                if contentType.defaultValue != nil, printDefault,
//                   storage.cursor < storage.buffer.count,
//                   storage.buffer[storage.cursor] != char {
//                    storage.eraseFromCursorToEndOfLine()
//                }
//                storage.write(char)
                
            default:
                storage.handle(next)
            }
        }
        
        return nil
    }
    
    private func __getLoop(printPrompt: Bool = true, body: @escaping (_ read: String) throws -> Content?) -> Content {
        if printPrompt {
            __printPrompt()
        }
        
        guard let read = __readline(printDefault: printPrompt && !self.prompt.description.hasSuffix("\n"))?.get() else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            fflush(stdout)
            return __getLoop(printPrompt: false, body: body)
        }
        
        if let defaultValue = contentType.defaultValue, read.isEmpty {
            return defaultValue
        }
        
        do {
            guard let value = try body(read),
                  try condition?(value) ?? true else { throw ReadError(reason: "Invalid Input.") }
            
            return value
        } catch {
            if let error = error as? ReadError {
                print("\u{1B}[31m" + error.reason + "\u{1B}[0m")
            } else {
                print("\u{1B}[31m" + (error as NSError).localizedDescription + "\u{1B}[0m")
            }
            Swift.print("\u{1B}[31mTry again: \u{1B}[0m", terminator: "")
            fflush(stdout)
            
            return __getLoop(printPrompt: false, body: body)
        }
    }
    
    /// Gets the value. This is guaranteed, as it would keep asking the user for correct input.
    public func get() -> Content {
        if let getLoop = contentType.overrideGetLoop {
            getLoop(self, contentType)
        } else {
            __getLoop(body: self.contentType.initializer)
        }
    }
    
    
    internal init(prompt: CommandPrintManager.Interpolation, contentType: CommandReadableContent<Content>, condition: ((_ content: Content) throws -> Bool)? = nil) {
        self.prompt = prompt
        self.condition = condition
        self.contentType = contentType
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
