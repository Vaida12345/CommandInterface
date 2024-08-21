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
    
    public override func readUserInput(configuration: _ReadUserInputConfiguration) -> String? {
        let defaultValue = formatter(defaultValue)
        var storage = StandardInputStorage()
        
        var autocompleteLength = storage.write(formatted: "\(defaultValue, modifier: .dim)")
        storage.move(to: .left, length: autocompleteLength)
        
        while let next = NextChar.consumeNext() {
            switch next {
            case .newline:
                Swift.print("\n", terminator: "")
                fflush(stdout)
                return storage.get()
                
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
                storage.handle(next)
            }
            
            let string = storage.get()
            if configuration.stopSequence.contains(where: { (try? $0.wholeMatch(in: string)) != nil }) {
                return string
            }
        }
        
        return nil
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
    
}
