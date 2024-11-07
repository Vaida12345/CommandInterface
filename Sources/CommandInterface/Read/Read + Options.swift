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
    
    public func makeInputReader(configuration: CommandInputReader.Configuration) -> InputReader {
        InputReader(options: self.options, bounded: self.bounded, configuration: configuration)
    }
    
    public typealias Content = String
    
    public final class InputReader: CommandInputReader {
        
        let options: [String]
        
        let bounded: Bool
        
        
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
        
        
        init(options: [String], bounded: Bool, configuration: Configuration) {
            self.options = options
            self.bounded = bounded
            
            super.init(configuration: configuration)
        }
        
        
        public override func handle(_ key: NextChar) throws -> String? {
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
                guard !matching.isEmpty else { return nil }
                let match = matching[matchingRotate]
                storage.clearEntered()
                
                storage.insertAtCursor(match)
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
                return try super.handle(key)
            }
            
            return nil
        }
        
        public override func didHandle(nextChar key: NextChar) -> String? {
            fflush(stdout);
            lastInput = key
            
            return super.didHandle(nextChar: key)
        }
    }
    
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
    
    public func makeInputReader(configuration: CommandInputReader.Configuration) -> CommandReadableOptions.InputReader {
        optionsReader.makeInputReader(configuration: configuration)
    }
    
    let optionsReader: CommandReadableOptions
    
    public func transform(input: String) throws -> Content? {
        Content(rawValue: input)
    }
    
    public typealias InputReader = CommandReadableOptions.InputReader
    
}


extension CommandReadable {
    
    /// Have the user enter a string from the given options.
    public static func options<Content>(
        _ options: some Sequence<Content>
    ) -> CommandReadableOptionsRawRepresentable<Content> where Content: RawRepresentable, Content.RawValue == String, Self == CommandReadableOptionsRawRepresentable<Content> {
        CommandReadableOptionsRawRepresentable<Content>(optionsReader: CommandReadableOptions(options: options.map(\.rawValue), bounded: true))
    }
    
    /// Have the user enter a string from the given options.
    public static func options<Content>(
        _ optionsType: Content.Type
    ) -> CommandReadableOptionsRawRepresentable<Content> where Content: RawRepresentable, Content.RawValue == String, Self == CommandReadableOptionsRawRepresentable<Content>, Content: CaseIterable {
        self.options(optionsType.allCases)
    }
    
}
