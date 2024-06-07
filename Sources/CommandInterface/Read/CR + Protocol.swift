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
    
    internal var contentKey: ContentKey
    
    internal let condition: ((String) throws -> Bool)?
    
    internal let initializer: (String) throws -> Content?
    
    internal let terminator: String
    
    internal let overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)?
    
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableContent<Bool> { .init(contentKey: .boolean, terminator: " [y/n]: ") { read in
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
    public static var textFile: CommandReadableContent<String> { .init(contentKey: .textFile, terminator: ":\n") { read in
        let filePath = __normalize(filePath: read)
        return try String(contentsOfFile: filePath)
    } }
    
    /// Indicates reading file path.
    public static var filePath: CommandReadableContent<String> { .init(contentKey: .filePath, terminator: ":\n", initializer: __normalize) }
    
    /// Indicates reading string.
    public static var string: CommandReadableContent<String> { .init(contentKey: .string, terminator: ":\n", initializer: { $0 }) }
    
    /// Indicates reading int.
    public static var int: CommandReadableContent<Int> { .init(contentKey: .int, terminator: ": ", initializer: Int.init) }
    
    /// Indicates reading double.
    public static var double: CommandReadableContent<Double> { .init(contentKey: .double, terminator: ": ", initializer: Double.init) }
    
    /// Indicates reading a file path that forms a FinderItem.
    public static var finderItem: CommandReadableContent<FinderItem> { .init(contentKey: .finderItem, terminator: ":\n") { FinderItem(at: __normalize(filePath: $0)) } }
    
    public static func options<Option>(from options: Option.Type) -> CommandReadableContent<Option> where Option: RawRepresentable & CaseIterable, Option.RawValue == String { .init(contentKey: .options, terminator: ": ") { read in
        guard let option = Option(rawValue: read) else { throw ReadError(reason: "Invalid Input: Input not in acceptable set") }
        return option
    } overrideGetLoop: { manager, content in
        var __raw = __setRawMode()
        defer {
            __resetTerminal(originalTerm: &__raw)
        }
        
        return content.__optionsGetLoop(manager: manager)
    } }
    
    
    init(contentKey: ContentKey, terminator: String, condition: ((String) throws -> Bool)? = nil, initializer: @escaping (String) throws -> Content?, overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)? = nil) {
        self.contentKey = contentKey
        self.terminator = terminator
        self.condition = condition
        self.initializer = initializer
        self.overrideGetLoop = overrideGetLoop
    }
    
    
    internal enum ContentKey: String {
        case boolean
        case textFile
        case filePath
        case string
        case int
        case double
        case finderItem
        case options
    }
    
    private func __askToChoose<Option>(from options: Array<Option>) -> String? where Option: RawRepresentable, Option.RawValue == String {
        
        var buffer: [Character] = []
        var cursor = 0
        
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
        
        func clearEntered() {
            // rotate to end
            while cursor > 0 {
                cursor -= 1
                Cursor.move(toRight: -1)
            }
            Terminal.eraseFromCursorToEndOfLine()
            buffer.removeAll()
        }
        
        while let key = __consumeNext() {
            switch key {
            case .up: // Up arrow, rotate
                if !showInitial {
                    showInitial = true
                } else {
                    rotateUp()
                }
                
                clearEntered()
                print(options[rotate].rawValue, terminator: "")
                
                buffer.append(contentsOf: options[rotate].rawValue)
                cursor += options[rotate].rawValue.count
            case .down: // Down arrow, rotate
                if !showInitial {
                    showInitial = true
                } else {
                    rotateDown()
                }
                
                clearEntered()
                print(options[rotate].rawValue, terminator: "")
                
                buffer.append(contentsOf: options[rotate].rawValue)
                cursor += options[rotate].rawValue.count
            case .right: // Right arrow, do nothing
                if cursor < buffer.count {
                    Cursor.move(toRight: 1)
                    cursor += 1
                }
            case .left: // Left arrow, do nothing
                if cursor > 0 {
                    Cursor.move(toRight: -1)
                    cursor -= 1
                }
            case .tab: // Tab key
                       //            print("    ", terminator: "")
                       //
                       //            buffer.append(contentsOf: "    ")
                       //            cursor += 4
                if lastInput != .tab {
                    __buffer = buffer
                } else {
                    rotateMatchingDown()
                }
                guard !matching.isEmpty else { continue }
                let match = matching[matchingRotate]
                clearEntered()
                
                print(match, terminator: "")
                
                buffer.append(contentsOf: match)
                cursor += match.count
            case .newline: // Enter key
                print("\n", terminator: "")
                
                return String(buffer)
                
                buffer.removeAll()
                cursor = 0
            case .backspace: // Backspace key
                if cursor > 0 {
                    Cursor.move(toRight: -1)
                    Swift.print("\(Terminal.escape)[P", terminator: "")
                    cursor -= 1
                    
                    if cursor < buffer.count {
                        buffer.remove(at: cursor)
                    }
                }
            case .string(let value): // Other characters
                print("\(Terminal.escape)[@\(value)", terminator: "")
                
                buffer.insert(contentsOf: value, at: cursor)
                cursor += value.count
            }
            
            fflush(stdout);
            lastInput = key
        }
        
        return nil
    }
    
    
    private func __optionsGetLoop(manager: CommandReadManager<Content>) -> Content where Content: RawRepresentable & CaseIterable, Content.RawValue == String {
        manager.__printPrompt(prompt: manager.prompt, terminator: self.terminator)
        
        guard let option = __askToChoose(from: Array(Content.allCases)) else {
            Terminal.bell()
            Swift.print("\u{1B}[31mTry again\u{1B}[0m: ", terminator: "")
            return __optionsGetLoop(manager: manager)
        }
        
        if let defaultValue = manager.defaultValue, option.isEmpty {
            
            let defaultValueModifier = CommandPrintManager.Modifier.default.foregroundColor(.secondary)
            Swift.print(defaultValueModifier.modify("using default value: \(defaultValue)"))
            
            return defaultValue
        }
        
        do {
            if let condition = manager.contentType.condition {
                guard try condition(option) else { throw ReadError(reason: "Invalid Input.") }
            }
            
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
