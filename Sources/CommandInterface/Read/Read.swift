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
    
    /// A sequence of `String`s that halts input processing and returns when the entire input matches any element in the sequence.
    ///
    /// The default implementation returns `[]`.
    var stopSequence: [Regex<Substring>] { get }
    
    /// The value formatter.
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
    func readUserInput() -> String?
    
    
    associatedtype Content
    
}


public extension CommandReadable {
    
    func formatter(content: Content) -> String {
        "\(content)"
    }
    
    func condition(content: Content) throws -> Bool {
        true
    }
    
    var stopSequence: [Regex<Substring>] {
        []
    }
    
    
    private func getLoopRecursion(manager: _CommandReadableManager<Content>) -> Content {
        Terminal.bell()
        return getLoop(manager)
    }
    
    func getLoop(_ manager: _CommandReadableManager<Content>) -> Content {
        DefaultInterface.default.print(manager.prompt, terminator: "")
        
        let line = Terminal.cursor.currentPosition().line
        
        guard let input = self.readUserInput() else {
            return getLoopRecursion(manager: manager)
        }
        
        do {
            guard let content = try transform(input: input),
                  try manager.condition?(content) ?? true,
                  try condition(content: content) else {
                throw ReadError(reason: "Invalid Input, please try again")
            }
            
            Terminal.eraseFromCursorToEndOfScreen()
            
            return content
        } catch {
            if let error = error as? ReadError {
                DefaultInterface.default.print("\(error.reason, modifier: .foregroundColor(.red))")
            } else {
                DefaultInterface.default.print("\((error as NSError).localizedDescription, modifier: .foregroundColor(.red))")
            }
            
            Terminal.cursor.moveTo(line: line, column: 0)
            Terminal.clearLine()
            
            return getLoopRecursion(manager: manager)
        }
    }
    
    func readUserInput() -> String? {
        var storage = StandardInputStorage()
        
        while let next = NextChar.consumeNext() {
            switch next {
            case .newline:
                Swift.print("\n", terminator: "")
                fflush(stdout)
                return storage.get()
                
            case .tab:
                // do nothing
                break
                
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



public struct _CommandReadableManager<Content> {
    
    internal let prompt: CommandPrintManager.Interpolation
    
    internal let condition: ((_ content: Content) throws -> Bool)?
    
}
