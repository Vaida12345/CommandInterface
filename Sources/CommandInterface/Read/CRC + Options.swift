//
//  File.swift
//  
//
//  Created by Vaida on 6/8/24.
//

import Foundation


extension CommandReadableContent where Content: RawRepresentable & CaseIterable, Content.RawValue == String {
    
    public static func options(from options: Content.Type) -> CommandReadableContent<Content> { .init(terminator: ": ") { read in
        guard let option = Content(rawValue: read) else { throw ReadError(reason: "Invalid Input: Input not in acceptable set") }
        return option
    } overrideGetLoop: { manager, content in
        content.__optionsGetLoop(manager: manager, shouldPrintPrompt: true)
    } }
    
    private func __askToChoose<Option>(from options: Array<Option>) -> String? where Option: RawRepresentable, Option.RawValue == String {
        
        var storage = StandardInputStorage()
        
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
            options.map(\.rawValue).filter { $0.hasPrefix(String(__buffer)) }
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
                storage.insertAtCursor(options[rotate].rawValue)
            case .down: // Down arrow, rotate
                if !showInitial {
                    showInitial = true
                } else {
                    rotateDown()
                }
                
                storage.clearEntered()
                storage.insertAtCursor(options[rotate].rawValue)
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
                storage.insertAtCursor(value)
            default:
                continue
            }
            
            fflush(stdout);
            lastInput = key
        }
        
        return nil
    }
    
    
    private func __optionsGetLoop(manager: CommandReadManager<Content>, shouldPrintPrompt: Bool) -> Content {
        if shouldPrintPrompt {
            manager.__printPrompt()
        }
        
        guard let option = __askToChoose(from: Array(Content.allCases)) else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            fflush(stdout)
            return __optionsGetLoop(manager: manager, shouldPrintPrompt: false)
        }
        
        if let defaultValue = manager.defaultValue, option.isEmpty {
            
            let defaultValueModifier = CommandPrintManager.Modifier.default.dim()
            Swift.print(defaultValueModifier.modify("using default value: \(defaultValue)"))
            
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
            
            return __optionsGetLoop(manager: manager, shouldPrintPrompt: false)
        }
    }
    
}
