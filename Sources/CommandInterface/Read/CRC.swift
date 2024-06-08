//
//  CommandRead Protocol.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Stratum
import Foundation


/// The interface for providing readable content.
public struct CommandReadableContent<Content> {
    
    internal let initializer: (String) throws -> Content?
    
    internal let overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)?
    
    internal let condition: ((Content) throws -> Bool)?
    
    internal let defaultValue: Content?
    
    internal let formatter: ((Content) -> String)?
    
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableContent<Bool> { .init { read in
        switch read.lowercased() {
        case "yes", "y", "true":
            return true
        case "no", "n", "false":
            return false
        default:
            return nil
        }
    } formatter: {
        $0 ? "yes" : "no"
    } }
    
    /// Indicates reading file path to a text file.
    public static var textFile: CommandReadableContent<String> { .init { read in
        let filePath = FinderItem.normalize(shellPath: read)
        return try String(contentsOfFile: filePath)
    } }
    
    /// Indicates reading file path.
    public static var filePath: CommandReadableContent<String> { .init(initializer: { FinderItem.normalize(shellPath: $0) }) }
    
    /// Indicates reading string.
    public static var string: CommandReadableContent<String> { .init(initializer: { $0 }) }
    
    /// Indicates reading int.
    public static var int: CommandReadableContent<Int> { .init(initializer: Int.init) }
    
    /// Indicates reading double.
    public static var double: CommandReadableContent<Double> { .init(initializer: Double.init) }
    
    /// Indicates reading a file path that forms a FinderItem.
    public static var finderItem: CommandReadableContent<FinderItem> { .init {
        FinderItem(at: FinderItem.normalize(shellPath: $0))
    } condition: {
        guard $0.exists else { throw ReadError(reason: "Invalid Input: The input filePath does not exist") }
        return true
    } }
    
    public static func customized(initializer: @escaping (String) throws -> Content?) -> CommandReadableContent<Content> {
        .init(initializer: initializer)
    }
    
    
    public func `default`(_ content: Content) -> CommandReadableContent {
        CommandReadableContent(defaultValue: content, initializer: initializer, overrideGetLoop: overrideGetLoop, condition: condition, formatter: formatter)
    }
    
    
    init(defaultValue: Content? = nil, initializer: @escaping (String) throws -> Content?, overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)? = nil, condition: ((Content) throws -> Bool)? = nil, formatter: ((Content) -> String)? = nil) {
        self.initializer = initializer
        self.overrideGetLoop = overrideGetLoop
        self.condition = condition
        self.defaultValue = defaultValue
        self.formatter = formatter
    }
    
}
