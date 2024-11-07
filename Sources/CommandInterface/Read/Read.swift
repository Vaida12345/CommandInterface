//
//  Read + Protocol.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


/// A content that can be read from ``CommandInterface/CommandInterface/read(_:prompt:condition:)``.
public protocol CommandReadable {
    
    /// The initializer that transforms `input` to `Content`.
    ///
    /// If `nil` is returned or the function throws an exception, the user is prompted to enter another input.
    func transform(input: String) throws -> Content?
    
    /// The condition that `content` needs to pass to be returned from ``CommandInterface/CommandInterface/read(_:prompt:condition:)``.
    ///
    /// The default implementation returns `true`.
    func condition(content: Content) throws -> Bool
    
    /// The value formatter.
    ///
    /// This function is used to format the default value when printed. The default implementation returns the default description.
    func formatter(content: Content) -> String
    
    /// The core. The function reads from the user.
    ///
    /// Useless you want to customize the get loop, use the default implementation.
    ///
    // FIXME: How about delegation & inheritance? Have a single structure handling the reading, with states being stored properties.
    func readUserInput(configuration: _ReadUserInputConfiguration) -> String?
    
    
    associatedtype Content
    
}


public extension CommandReadable {
    
    func formatter(content: Content) -> String {
        "\(content)"
    }
    
    func condition(content: Content) throws -> Bool {
        true
    }
    
    
    private func getLoopRecursion(manager: _CommandReadableManager<Content>, printPrompt: Bool) -> Content {
        Terminal.bell()
        return getLoop(manager, printPrompt: printPrompt)
    }
    
    func readUserInput(configuration: _ReadUserInputConfiguration) -> String? {
        _defaultReadUserInput(configuration: configuration)
    }
    
    func _defaultReadUserInput(configuration: _ReadUserInputConfiguration) -> String? {
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
            if configuration.stopSequence.contains(where: { (try? $0.wholeMatch(in: string)) != nil }) {
                return string
            }
        }
        
        return nil
    }
    
}


extension CommandReadable {
    
    /// The core. The function recursively called to prompt user for input.
    ///
    /// Useless you want to customize the get loop, use the default implementation.
    func getLoop(_ manager: _CommandReadableManager<Content>, printPrompt: Bool = true) -> Content {
        let currentPosition = Terminal.cursor.currentPosition().line
        
        if printPrompt {
            DefaultInterface.default.print(manager.prompt, terminator: "")
        }
        
        let afterPromptPosition = Terminal.cursor.currentPosition()
        
        guard let input = self.readUserInput(configuration: .default) else {
            return getLoopRecursion(manager: manager, printPrompt: true)
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
            let errorDescription: String
            if let error = error as? ReadError {
                errorDescription = error.reason
            } else {
                errorDescription = (error as NSError).localizedDescription
            }
            
            // restore state
            Terminal.cursor.moveTo(line: afterPromptPosition.line, column: afterPromptPosition.column)
            Terminal.eraseFromCursorToEndOfScreen()
            
            DefaultInterface.default.print("\n\(errorDescription, modifier: .foregroundColor(.red))")
            
            Terminal.cursor.moveTo(line: afterPromptPosition.line, column: afterPromptPosition.column)
            
            return getLoopRecursion(manager: manager, printPrompt: false)
        }
    }
    
}


public struct _CommandReadableManager<Content> {
    
    internal let prompt: CommandPrintManager.Interpolation
    
    internal let condition: ((_ content: Content) throws -> Bool)?
    
}


public struct _ReadUserInputConfiguration {
    
    internal let stopSequence: [Regex<Substring>]
    
    static let `default` = _ReadUserInputConfiguration(stopSequence: [])
    
}
