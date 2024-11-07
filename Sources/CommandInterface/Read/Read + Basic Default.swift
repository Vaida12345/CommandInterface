//
//  Read + Default.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


/// Generic readable content with default value.
public final class CommandReadableDefaultableGeneric<Content>: CommandReadableGeneric<Content> {
    
    public let defaultValue: Content
    
    public func withDefaultValue(_ defaultValue: Content) -> Self {
        Self(transform: self.transform, condition: self.condition, formatter: self.formatter, defaultValue: defaultValue)
    }
    
    init(
        transform: @escaping (_: String) throws -> Content?,
        condition: @escaping (_: Content) throws -> Bool,
        formatter: @escaping (_: Content) -> String,
        defaultValue: Content
    ) {
        self.defaultValue = defaultValue
        
        super.init(transform: transform, condition: condition, formatter: formatter)
    }
    
    public override func makeInputReader(configuration: CommandInputReader.Configuration) -> InputReader {
        InputReader(formatter: formatter, defaultValue: defaultValue, configuration: configuration)
    }
    
    
    public final class InputReader: CommandInputReader {
        
        let defaultValue: String
        
        var autocompleteLength: Int
        
        
        init(formatter: @escaping (_: Content) -> String, defaultValue: Content, configuration: Configuration) {
            self.defaultValue = formatter(defaultValue)
            self.autocompleteLength = 0 // dummpy value
            
            var storage = StandardInputStorage()
            self.autocompleteLength = storage.write(formatted: "\(self.defaultValue, modifier: .dim)")
            storage.move(to: .left, length: autocompleteLength)
            
            super.init(configuration: configuration, storage: storage)
        }
        
        public override func handle(_ next: NextChar) throws -> String? {
            switch next {
            case .right:
                if storage.cursor < storage.count - autocompleteLength {
                    storage.handle(next)
                } else {
                    let content = storage.getBeforeCursor()
                    if defaultValue.hasPrefix(content), autocompleteLength != 0 {
                        var value = defaultValue
                        value.removeFirst(content.count)
                        let rightCount = value.count - 1
                        storage.write(value)
                        autocompleteLength = 0
                        storage.move(to: .left, length: rightCount)
                    }
                }
                
            case .tab:
                let content = storage.getBeforeCursor()
                if defaultValue.hasPrefix(content), autocompleteLength != 0 {
                    var value = defaultValue
                    value.removeFirst(content.count)
                    storage.write(value)
                    autocompleteLength = 0
                }
                
            case .delete:
                guard storage.cursor != 0 else { break }
                if autocompleteLength != 0 {
                    let shift = storage.count - storage.cursor - autocompleteLength
                    storage.move(to: .right, length: shift)
                    storage.deleteAfterCursor(count: autocompleteLength)
                    storage.move(to: .left, length: shift)
                    autocompleteLength = 0
                }
                storage.handle(next)
                
            case .char(let char):
                if storage.getCursorChar() != char {
                    storage.eraseFromCursorToEndOfLine()
                    autocompleteLength = 0
                } else {
                    autocompleteLength -= 1
                }
                storage.write(char)
                
            default:
                return try super.handle(next)
            }
            
            return nil
        }
        
    }
    
}
