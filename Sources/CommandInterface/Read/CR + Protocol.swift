//
//  CommandRead Protocol.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Stratum
import Foundation


/// A protocol indicating its `Content` is readable from stdin.
public protocol CommandReadable {
    
    associatedtype Content
    
}


/// The interface for providing readable content.
public struct CommandReadableContent<Content>: CommandReadable {
    
    internal let initializer: (String) throws -> Content?
    
    internal let terminator: String
    
    internal let overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)?
    
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableContent<Bool> { .init(terminator: " [y/n]: ") { read in
        switch read.lowercased() {
        case "yes", "y":
            return true
        case "no", "n":
            return false
        default:
            return nil
        }
    } }
    
    /// Indicates reading file path to a text file.
    public static var textFile: CommandReadableContent<String> { .init(terminator: ":\n") { read in
        let filePath = __normalize(filePath: read)
        return try String(contentsOfFile: filePath)
    } }
    
    /// Indicates reading file path.
    public static var filePath: CommandReadableContent<String> { .init(terminator: ":\n", initializer: __normalize) }
    
    /// Indicates reading string.
    public static var string: CommandReadableContent<String> { .init(terminator: ":\n", initializer: { $0 }) }
    
    /// Indicates reading int.
    public static var int: CommandReadableContent<Int> { .init(terminator: ": ", initializer: Int.init) }
    
    /// Indicates reading double.
    public static var double: CommandReadableContent<Double> { .init(terminator: ": ", initializer: Double.init) }
    
    /// Indicates reading a file path that forms a FinderItem.
    public static var finderItem: CommandReadableContent<FinderItem> { .init(terminator: ":\n") { FinderItem(at: __normalize(filePath: $0)) } }
    
    public static func options<Option>(from options: Option.Type) -> CommandReadableContent<Option> where Option: RawRepresentable & CaseIterable, Option.RawValue == String { .init(terminator: ": ") { read in
        guard let option = Option(rawValue: read) else { throw ReadError(reason: "Invalid Input: Input not in acceptable set") }
        return option
    } overrideGetLoop: { manager, content in
        var __raw = __setRawMode()
        defer {
            __resetTerminal(originalTerm: &__raw)
        }
        
        return content.__optionsGetLoop(manager: manager)
    } }
    
    public static func customized(initializer: @escaping (String) throws -> Content?) -> CommandReadableContent<Content> {
        .init(terminator: ": ", initializer: initializer)
    }
    
    
    private init(terminator: String, initializer: @escaping (String) throws -> Content?, overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)? = nil) {
        self.terminator = terminator
        self.initializer = initializer
        self.overrideGetLoop = overrideGetLoop
    }
    
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
    
    
    private func __optionsGetLoop(manager: CommandReadManager<Content>) -> Content where Content: RawRepresentable & CaseIterable, Content.RawValue == String {
        manager.__printPrompt(prompt: manager.prompt, terminator: self.terminator)
        fflush(stdout)
        
        guard let option = __askToChoose(from: Array(Content.allCases)) else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            return __optionsGetLoop(manager: manager)
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
            
            return __optionsGetLoop(manager: manager)
        }
    }
    
}
