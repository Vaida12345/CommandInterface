//
//  Read + Default.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


/// Generic readable content with default value.
public struct CommandReadableDefaultableGeneric<Content>: CommandReadable {
    
    let transform: (_ input: String) throws -> Content?
    
    let condition: (_ content: Content) throws -> Bool
    
    let formatter: (_ content: Content) -> String
    
    public let stopSequence: [Regex<Substring>]
    
    public let defaultValue: Content
    
    
    public func transform(input: String) throws -> Content? {
        try transform(input)
    }
    
    public func condition(content: Content) throws -> Bool {
        try condition(content)
    }
    
    public func formatter(content: Content) -> String {
        formatter(content)
    }
    
    
    public func readUserInput() -> String? {
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
                    var rightCount = 0
                    while storage.cursor < storage.count {
                        storage.move(to: .right)
                        rightCount += 1
                    }
                    for _ in 1...autocompleteLength {
                        storage.deleteBeforeCursor()
                        rightCount -= 1
                    }
                    autocompleteLength = 0
                    storage.move(to: .left, length: rightCount)
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
            if self.stopSequence.contains(where: { (try? $0.wholeMatch(in: string)) != nil }) {
                return string
            }
        }
        
        return nil
    }
    
}


extension CommandReadableDefaultableGeneric {
    
    /// Provides the stop sequence.
    ///
    /// Inputs with stop sequences stops immediately when matched. This would usually indicate that a newline is not inserted. For example
    ///
    /// ```swift
    /// let input = self.read(.string.stopSequence(/\?/), prompt: "read: ")
    /// print(">>>> \(input)")
    /// // read: ?>>>?\n
    /// ```
    ///
    /// - Parameters:
    ///   - sequence: A sequence of `String`s that halts input processing and returns when the entire input matches any element in the sequence.
    public func stopSequence(_ sequence: [Regex<Substring>]) -> CommandReadableDefaultableGeneric {
        CommandReadableDefaultableGeneric(transform: self.transform, condition: self.condition, formatter: self.formatter, stopSequence: sequence, defaultValue: defaultValue)
    }
    
    /// Provides the stop sequence.
    ///
    /// Inputs with stop sequences stops immediately when matched. This would usually indicate that a newline is not inserted. For example
    ///
    /// ```swift
    /// let input = self.read(.string.stopSequence(/\?/), prompt: "read: ")
    /// print(">>>> \(input)")
    /// // read: ?>>>?\n
    /// ```
    ///
    /// - Parameters:
    ///   - sequence: A sequence of `String`s that halts input processing and returns when the entire input matches any element in the sequence.
    public func stopSequence(_ sequence: Regex<Substring>...) -> CommandReadableDefaultableGeneric {
        self.stopSequence(sequence)
    }
    
}
