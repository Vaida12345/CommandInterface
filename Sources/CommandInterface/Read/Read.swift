//
//  Read + Protocol.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


/// A content that can be read from ``CommandInterface/CommandInterface/read(_:prompt:condition:)``.
public protocol CommandReadable {
    
    /// The initializer that transforms `input` to ``Content``.
    ///
    /// If `nil` is returned or the function throws an exception, the user is prompted to enter another input.
    func transform(input: String) throws -> Content?
    
    /// The condition that `content` needs to pass to be returned from ``CommandInterface/CommandInterface/read(_:prompt:condition:)``.
    ///
    /// The default implementation returns `true`.
    func condition(content: Content) throws -> Bool
    
    /// The default value.
    ///
    /// The default implementation returns `nil`.
    var defaultValue: Content? { get }
    
    /// A sequence of `String`s that halts input processing and returns when the entire input matches any element in the sequence.
    ///
    /// The default implementation returns `[]`.
    var stopSequence: [Regex<Substring>] { get }
    
    /// The default value formatter.
    ///
    /// This function is used to format the default value when printed. The default implementation returns the default description.
    func formatter(content: Content) -> String
    
    
    /// The core. The function recursively called to prompt user for input.
    ///
    /// Useless you want to customize the get loop, use the default implementation.
    func getLoop(_ manager: _CommandReadableManager<Content>) -> Content
    
    /// The core. The function reads from the user.
    ///
    /// Useless you want to customize the get loop, use the default implementation.
    func readUserInput() -> StandardInputStorage?
    
    
    associatedtype Content
    
}


public extension CommandReadable {
    
    func formatter(content: Content) -> String {
        "\(content)"
    }
    
    func condition(content: Content) throws -> Bool {
        true
    }
    
    var defaultValue: Content? {
        nil
    }
    
    var stopSequence: [Regex<Substring>] {
        []
    }
    
    
    private func getLoopRecursion(manager: _CommandReadableManager<Content>) -> Content {
        Terminal.bell()
        DefaultInterface.default.print("\("Try Again\n", modifier: .foregroundColor(.yellow), .bold)", terminator: "")
        return getLoop(manager)
    }
    
    func getLoop(_ manager: _CommandReadableManager<Content>) -> Content {
        DefaultInterface.default.print(manager.prompt, terminator: "")
        
        guard let input = self.readUserInput()?.get() else {
            return getLoopRecursion(manager: manager)
        }
        
        if input.isEmpty, let defaultValue {
            return defaultValue
        }
        
        do {
            guard let content = try transform(input: input),
                  try manager.condition?(content) ?? true,
                  try condition(content: content) else {
                throw ReadError(reason: "Invalid Input.")
            }
            
            return content
        } catch {
            if let error = error as? ReadError {
                DefaultInterface.default.print("\(error.reason, modifier: .foregroundColor(.red))")
            } else {
                DefaultInterface.default.print("\((error as NSError).localizedDescription, modifier: .foregroundColor(.red))")
            }
            
            return getLoopRecursion(manager: manager)
        }
    }
    
    func readUserInput() -> StandardInputStorage? {
        var storage = StandardInputStorage()
        let defaultValue = self.defaultValue.map(formatter(content:))
        
        if let defaultValue {
            let len = storage.insertAtCursor(formatted: "\(defaultValue, modifier: .dim)")
            storage.move(to: .left, length: len)
        }
        
        while let next = NextChar.consumeNext() {
            switch next {
            case .newline:
                Swift.print("\n", terminator: "")
                fflush(stdout)
                return storage
                
            case .tab:
                if let defaultValue,
                   defaultValue.hasPrefix(storage.getBeforeCursor()) {
                    var value = defaultValue
                    value.removeFirst(storage.getBeforeCursor().count)
                    storage.write(value)
                }
                
            case .char(let char):
                if defaultValue != nil,
                   storage.getCursorChar() != char {
                    storage.eraseFromCursorToEndOfLine()
                }
                storage.write(char)
                
            default:
                storage.handle(next)
            }
            
            let string = storage.get()
            if self.stopSequence.contains(where: { (try? $0.wholeMatch(in: string)) != nil }) {
                return storage
            }
        }
        
        return nil
    }
    
}



public struct _CommandReadableManager<Content> {
    
    internal let prompt: CommandPrintManager.Interpolation
    
    internal let condition: ((_ content: Content) throws -> Bool)?
    
}
