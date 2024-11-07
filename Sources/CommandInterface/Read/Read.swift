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
    
    /// Makes an input reader that reads from stdin.
    ///
    /// Useless you want to customize the get loop, use the default implementation.
    func makeInputReader(_configuration: CommandInputReader._Configuration) -> InputReader
    
    
    associatedtype Content
    
    associatedtype InputReader: CommandInputReader
    
}


public extension CommandReadable {
    
    func formatter(content: Content) -> String {
        "\(content)"
    }
    
    func condition(content: Content) throws -> Bool {
        true
    }
    
    func makeInputReader(_configuration: CommandInputReader._Configuration) -> InputReader where InputReader == CommandInputReader {
        CommandInputReader(configuration: _configuration)
    }
    
}
