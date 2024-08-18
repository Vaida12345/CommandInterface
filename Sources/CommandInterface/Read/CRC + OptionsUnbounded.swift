//
//  File.swift
//  
//
//  Created by Vaida on 6/8/24.
//

import Foundation


extension CommandReadableContent where Content == String {
    
    /// Different from ``options(from:)``, the output could be any `String`.
    public static func unboundedOptions<Option>(from options: Option.Type) -> CommandReadableContent<Content> where Option: RawRepresentable & CaseIterable, Option.RawValue == String { .init { read in
        read
    } overrideGetLoop: { manager, content in
        content.__optionsGetLoop(manager: manager, shouldPrintPrompt: true, options: Option.allCases.map(\.rawValue))
    } }
    
    /// Different from ``options(from:)``, the output could be any `String`.
    public static func unboundedOptions(from options: [String]) -> CommandReadableContent<Content> { .init { read in
        read
    } overrideGetLoop: { manager, content in
        content.__optionsGetLoop(manager: manager, shouldPrintPrompt: true, options: options)
    } }
    
    func __askToChoose(from options: Array<String>, defaultValueLiteral: String?) -> String? {
        
        var storage = StandardInputStorage()
        var override = true // override for default
        
        if let defaultValue = defaultValueLiteral {
            let len = storage.insertAtCursor(formatted: "\(defaultValue, modifier: .dim)")
            storage.move(to: .left, length: len)
        }
        
        var rotate = 0
        func rotateUp() {
            rotate += options.count - 1
            rotate = rotate % options.count
        }
        func rotateDown() {
            rotate += 1
            rotate = rotate % options.count
        }
        var showInitial = false
        
        var matchingRotate = 0
        var matching: [String] {
            options.filter { $0.hasPrefix(String(__buffer)) }
        }
        func rotateMatchingDown() {
            matchingRotate += 1
            matchingRotate = matchingRotate % matching.count
        }
        
        var lastInput: NextChar? = nil
        var __buffer: [Character] = []
        
        while let key = __consumeNext() {
            switch key {
            case .up: // Up arrow, rotate
                if !showInitial {
                    showInitial = true
                } else {
                    rotateUp()
                }
                
                storage.clearEntered()
                storage.insertAtCursor(options[rotate])
            case .down: // Down arrow, rotate
                if !showInitial {
                    showInitial = true
                } else {
                    rotateDown()
                }
                
                storage.clearEntered()
                storage.insertAtCursor(options[rotate])
            case .right: // Right arrow, do nothing
                storage.move(to: .right)
            case .left: // Left arrow, do nothing
                storage.move(to: .left)
            case .tab: // Tab key
                       //            print("    ", terminator: "")
                       //
                       //            buffer.append(contentsOf: "    ")
                       //            cursor += 4
                if lastInput != .tab {
                    __buffer = storage.buffer
                } else {
                    rotateMatchingDown()
                }
                guard !matching.isEmpty else { continue }
                let match = matching[matchingRotate]
                storage.clearEntered()
                
                storage.insertAtCursor(match)
            case .newline: // Enter key
                print("\n", terminator: "")
                
                return String(storage.buffer)
            case .delete: // Backspace key
                storage.deleteBeforeCursor()
            case .char(let value): // Other characters
                if override {
                    if storage.buffer.count > storage.cursor, value == storage.buffer[storage.cursor] {
                        storage.write(value)
                    } else {
                        storage.eraseFromCursorToEndOfLine()
                        storage.write(value)
                        override = false
                    }
                } else {
                    storage.insertAtCursor(value)
                }
            default:
                continue
            }
            
            fflush(stdout);
            lastInput = key
        }
        
        return nil
    }
    
    
    private func __optionsGetLoop(manager: CommandReadManager<Content>, shouldPrintPrompt: Bool, options: [String]) -> Content {
        if shouldPrintPrompt {
            manager.__printPrompt()
        }
        
        var defaultValueLiteral: String? {
            if let defaultValue = manager.contentType.defaultValue, shouldPrintPrompt {
                return manager.contentType.formatter?(defaultValue) ?? "\(defaultValue)"
            }
            return nil
        }
        
        guard let option = __askToChoose(from: options, defaultValueLiteral: defaultValueLiteral) else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            fflush(stdout)
            return __optionsGetLoop(manager: manager, shouldPrintPrompt: false, options: options)
        }
        
        if let defaultValue = manager.contentType.defaultValue, option.isEmpty {
            return defaultValue
        }
        
        do {
            guard let value = try self.initializer(option) else { throw ReadError(reason: "Invalid Input.") }
            
            let condition = try manager.condition?(value)
            guard condition ?? true else { throw ReadError(reason: "Invalid Input.") }
            
            return value
        } catch {
            if let error = error as? ReadError {
                print("\u{1B}[31m" + error.reason + "\u{1B}[0m")
            } else {
                print("\u{1B}[31m" + (error as NSError).localizedDescription + "\u{1B}[0m")
            }
            Swift.print("\u{1B}[31mTry again: \u{1B}[0m", terminator: "")
            fflush(stdout)
            
            return __optionsGetLoop(manager: manager, shouldPrintPrompt: false, options: options)
        }
    }
    
}
