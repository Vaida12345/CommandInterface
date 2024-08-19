//
//  Read + Options.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


public struct CommandReadableOptions: CommandReadable {
    
    let options: [String]
    
    public func transform(input: String) throws -> Content? {
        input
    }
    
    public var defaultValue: Content?
    
    public func condition(content: String) throws -> Bool {
        options.contains(content)
    }
    
    public func readUserInput() -> String? {
        var storage = StandardInputStorage()
        var override = true // override for default
        let defaultValue = self.defaultValue.map(formatter(content:))
        
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
        var __buffer: String = ""
        
        while let key = NextChar.consumeNext() {
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
                    __buffer = storage.get()
                } else {
                    rotateMatchingDown()
                }
                guard !matching.isEmpty else { continue }
                let match = matching[matchingRotate]
                storage.clearEntered()
                
                storage.insertAtCursor(match)
            case .newline: // Enter key
                print("\n", terminator: "")
                
                return storage.get()
            case .delete: // Backspace key
                storage.deleteBeforeCursor()
            case .char(let value): // Other characters
                if override {
                    if value == storage.getCursorChar() {
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
    
    
    public typealias Content = String
    
}

extension CommandReadable {
    
    public static func options(
        _ options: [String]
    ) -> CommandReadableOptions where Self == CommandReadableOptions {
        CommandReadableOptions(options: options)
    }
    
    // where Option: RawRepresentable & CaseIterable, Option.RawValue == String, Self == CommandReadableOptions<Option>
    
}


extension CommandReadableOptions {
    
    /// Provides the default value.
    public func `default`(_ content: Content) -> CommandReadableOptions {
        CommandReadableOptions(options: self.options, defaultValue: defaultValue)
    }
    
}
