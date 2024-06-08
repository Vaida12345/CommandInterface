//
//  File.swift
//  
//
//  Created by Vaida on 6/8/24.
//

import Foundation
import Stratum


extension CommandReadableContent where Content == String {
    
    public static func reformattingString(formatter: @escaping (String) -> CommandPrintManager.Interpolation) -> CommandReadableContent {
        .init(initializer: { $0 }) { manager, content in
            content.__getLoop(manager: manager, printPrompt: true, formatter: formatter)
        }
    }
    
    func __readline(printDefault: Bool, manager: CommandReadManager<Content>, formatter: (String) -> CommandPrintManager.Interpolation) -> StandardInputStorage? {
        var storage = StandardInputStorage()
        
        var defaultValueLiteral: String? {
            if let defaultValue = manager.contentType.defaultValue, printDefault {
                return manager.contentType.formatter?(defaultValue) ?? "\(defaultValue)"
            }
            return nil
        }
        
        if let defaultValue = defaultValueLiteral {
            let len = storage.insertAtCursor(formatted: "\(defaultValue, modifier: .dim)")
            storage.move(to: .left, length: len)
        }
        
        while let next = __consumeNext() {
            switch next {
            case .newline:
                Swift.print("\n", terminator: "")
                fflush(stdout)
                return storage
                
            case .tab:
                if let defaultValue = defaultValueLiteral,
                   defaultValue.hasPrefix(String(storage.buffer)),
                   storage.cursor == storage.buffer.count || storage.buffer.isEmpty {
                    var value = defaultValue
                    if !storage.buffer.isEmpty {
                        for _ in 1...storage.cursor {
                            value.removeFirst()
                        }
                    }
                    storage.insertAtCursor(value)
                }
                
            case .char(let char):
                if manager.contentType.defaultValue != nil, printDefault,
                   storage.cursor < storage.buffer.count,
                   storage.buffer[storage.cursor] != char {
                    storage.eraseFromCursorToEndOfLine()
                }
                storage.insertAtCursor(char)
                
            default:
                storage.handle(next)
            }
            
            if next != .left && next != .right && next != .delete {
                let contents = storage.clearEntered()
                storage.insertAtCursor(formatted: formatter(contents))
                //            Swift.print(contents.replacingOccurrences(of: "\\", with: ""), terminator: "")
                fflush(stdout)
            }
        }
        
        return nil
    }
    
    
    private func __getLoop(manager: CommandReadManager<Content>, printPrompt: Bool, formatter: (String) -> CommandPrintManager.Interpolation) -> Content {
        
        if printPrompt {
            manager.__printPrompt()
        }
        
        guard let read = __readline(printDefault: printPrompt && !manager.prompt.hasSuffix("\n"), manager: manager, formatter: formatter) else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            fflush(stdout)
            return __getLoop(manager: manager, printPrompt: false, formatter: formatter)
        }
        
        if let defaultValue = manager.contentType.defaultValue, read.buffer.isEmpty {
            return defaultValue
        }
        
        do {
            let contents = read.get()
            let condition = try condition?(contents)
            guard condition ?? true else { throw ReadError(reason: "Invalid Input.") }
            
            return contents
        } catch {
            if let error = error as? ReadError {
                print("\u{1B}[31m" + error.reason + "\u{1B}[0m")
            } else {
                print("\u{1B}[31m" + (error as NSError).localizedDescription + "\u{1B}[0m")
            }
            Swift.print("\u{1B}[31mTry again: \u{1B}[0m", terminator: "")
            fflush(stdout)
            
            return __getLoop(manager: manager, printPrompt: false, formatter: formatter)
        }
    }
    
}
