//
//  Read + Options.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


public struct CommandReadableOptions: CommandReadable {
    
    let options: [String]
    
    let bounded: Bool
    
    
    public func transform(input: String) throws -> Content? {
        input
    }
    
    public func condition(content: String) throws -> Bool {
        !bounded || options.contains(content)
    }
    
    public func readUserInput(configuration: _ReadUserInputConfiguration) -> String? {
        var storage = StandardInputStorage()
        var override = true // override for default
        
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
                rotateUp()
                showInitial = true
                
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
            case .tab: // Tab key
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
                storage.handle(key)
            }
            
            fflush(stdout);
            lastInput = key
            
            let string = storage.get()
            if configuration.stopSequence.contains(where: { (try? $0.wholeMatch(in: string)) != nil }) {
                return string
            }
        }
        
        return nil
    }
    
    
    public typealias Content = String
    
}

extension CommandReadable where Self == CommandReadableOptions {
    
    /// Have the user enter a string from the given options.
    public static func options(
        _ options: [String]
    ) -> CommandReadableOptions {
        CommandReadableOptions(options: options, bounded: true)
    }
    
    /// Have the user enter a string from the given options.
    public static func options(
        _ options: String...
    ) -> CommandReadableOptions {
        Self.options(options)
    }
    
    /// Ask the user for a string.
    public static func unboundedOptions(
        _ options: [String]
    ) -> CommandReadableOptions {
        CommandReadableOptions(options: options, bounded: false)
    }
    
}



public struct CommandReadableOptionsRawRepresentable<Content>: CommandReadable where Content: RawRepresentable, Content.RawValue == String {
    
    let optionsReader: CommandReadableOptions
    
    public func transform(input: String) throws -> Content? {
        Content(rawValue: input)
    }
    
}


extension CommandReadable {
    
    /// Have the user enter a string from the given options.
    public static func options<Content>(
        _ options: [Content]
    ) -> CommandReadableOptionsRawRepresentable<Content> where Content: RawRepresentable, Content.RawValue == String, Self == CommandReadableOptionsRawRepresentable<Content> {
        CommandReadableOptionsRawRepresentable<Content>(optionsReader: CommandReadableOptions(options: options.map(\.rawValue), bounded: true))
    }
    
}
