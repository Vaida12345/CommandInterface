//
//  Read + Terminal.swift
//  CommandInterface
//
//  Created by Vaida on 11/8/24.
//

import Foundation


extension Terminal {
    
    /// Reads a value from stdin.
    ///
    /// Use this the way you use `SwiftUI` views and modifiers. for example,
    ///
    /// ```swift
    /// let value = read(.double, prompt: "Enter a value",
    ///                  default: 3.14) { $0 > 0 }
    /// ```
    ///
    /// ## Condition Modifier
    /// Sets the condition that must meet for the read content considered succeed.
    ///
    /// In this example, the given text file must contain "Hello".
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file") { content in
    ///     content.contains("Hello")
    /// }
    /// ```
    ///
    /// You can also provide the reason for failure using `throw`.
    /// ```swift
    /// self.read(.textFile, prompt: "Enter a path for text file") { content in
    ///     guard content.contains("Hello") else {
    ///         throw ReadError(reason: "Source not contain \"Hello\"")
    ///     }
    ///     return true
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - contentType: The content type for reading. See ``CommandReadable``.
    ///   - prompt: The prompt shown to the user.
    ///   - condition: The condition that will be matched against.
    public static func read<T>(
        _ contentType: T,
        prompt: CommandPrintManager.Interpolation,
        condition: ((_ content: T.Content) throws -> Bool)? = nil
    ) throws -> T.Content where T: CommandReadable {
        try getLoop(of: contentType, prompt: prompt, condition: condition)
    }
    
    
    private static func getLoop<T>(
        of contentType: T,
        prompt: CommandPrintManager.Interpolation,
        condition: ((_ content: T.Content) throws -> Bool)?,
        printPrompt: Bool = true
    ) throws -> T.Content where T: CommandReadable {
        if printPrompt {
            Terminal.print(prompt, terminator: "")
        }
        
#if DEBUG
        // if under test env, disable position checking, as Xcode Terminal does not support position reading.
        let afterPromptPosition: (line: Int, column: Int)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
            afterPromptPosition = (0, 0)
        } else {
            afterPromptPosition = Terminal.cursor.currentPosition()
        }
#endif
        
        guard let input = try contentType.makeInputReader(configuration: .default).read() else {
            Terminal.bell()
            return try getLoop(of: contentType, prompt: prompt, condition: condition, printPrompt: false)
        }
        
        do {
            guard let content = try contentType.transform(input: input),
                  try condition?(content) ?? true,
                  try contentType.condition(content: content) else {
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
            
            Terminal.print("\n\(errorDescription, modifier: .foregroundColor(.red))")
            
            Terminal.cursor.moveTo(line: afterPromptPosition.line, column: afterPromptPosition.column)
            
            Terminal.bell()
            return try getLoop(of: contentType, prompt: prompt, condition: condition, printPrompt: false)
        }
    }
    
}
