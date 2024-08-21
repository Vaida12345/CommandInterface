//
//  Read + Basic.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Stratum


/// Generic readable content.
public class CommandReadableGeneric<Content>: CommandReadableDefaultable {
    
    let transform: (_ input: String) throws -> Content?
    
    let condition: (_ content: Content) throws -> Bool
    
    let formatter: (_ content: Content) -> String
    
    
    public func transform(input: String) throws -> Content? {
        try transform(input)
    }
    
    public func condition(content: Content) throws -> Bool {
        try condition(content)
    }
    
    public func formatter(content: Content) -> String {
        formatter(content)
    }
    
    public func readUserInput(configuration: _ReadUserInputConfiguration) -> String? {
        _defaultReadUserInput(configuration: configuration)
    }
    
    
    public static func transform(
        transform: @escaping (_ input: String) throws -> Content?,
        condition: @escaping (_ content: Content) throws -> Bool = { _ in true },
        formatter: @escaping (_ content: Content) -> String = { "\($0)" }
    ) -> CommandReadableGeneric {
        CommandReadableGeneric(transform: transform, condition: condition, formatter: formatter)
    }
    
    init(
        transform: @escaping (_: String) throws -> Content?,
        condition: @escaping (_: Content) throws -> Bool,
        formatter: @escaping (_: Content) -> String
    ) {
        self.transform = transform
        self.condition = condition
        self.formatter = formatter
    }
    
    
    /// Provides the default value.
    public func `default`(_ defaultValue: Content) -> CommandReadableDefaultableGeneric<Content> {
        CommandReadableDefaultableGeneric(transform: self.transform, condition: self.condition, formatter: self.formatter, defaultValue: defaultValue)
    }
    
}


extension CommandReadable where Self == CommandReadableGeneric<Bool> {
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableGeneric<Content> {
        .transform { input in
            switch input.lowercased() {
            case "yes", "y", "true":
                return true
            case "no", "n", "false":
                return false
            default:
                throw ReadError(reason: "Not a boolean value.")
            }
        } formatter: {
            $0 ? "yes" : "no"
        }
    }
    
}

extension CommandReadable where Self == CommandReadableGeneric<String> {
    
    /// Indicates reading `String` from a text file as indicated by the input path.
    public static var textFile: CommandReadableGeneric<Content> {
        .transform { input in
            let filePath = FinderItem.normalize(shellPath: input)
            return try FinderItem(at: filePath).load(.string())
        }
    }
    
    /// Indicates reading string.
    public static var string: CommandReadableGeneric<Content> {
        .transform { input in
            return input
        }
    }
    
}

extension CommandReadable where Self == CommandReadableGeneric<FinderItem> {
    
    /// Indicates reading a file path that forms a FinderItem.
    public static var finderItem: CommandReadableGeneric<Content> {
        .transform { input in
            return FinderItem(at: FinderItem.normalize(shellPath: input))
        } condition: {
            guard $0.exists else { throw ReadError(reason: "Invalid Input: The input filePath does not exist") }
            return true
        }
    }
    
}


extension CommandReadable {
    
    /// A customized readable content
    ///
    /// - Parameters:
    ///   - transform: The initializer that transforms `input` to `Content`.
    ///   - condition: The condition that `content` needs to pass to be returned from ``CommandInterface/CommandInterface/read(_:prompt:condition:)``.
    ///   - formatter: The default value formatter. This function is used to format the default value when printed. The default implementation returns the default description.
    public static func transform(
        transform: @escaping (_ input: String) throws -> Content?,
        condition: @escaping (_ content: Content) throws -> Bool = { _ in true },
        formatter: @escaping (_ content: Content) -> String = { "\($0)" }
    ) -> CommandReadableGeneric<Content> {
        CommandReadableGeneric(transform: transform, condition: condition, formatter: formatter)
    }
    
}
