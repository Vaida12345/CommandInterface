//
//  CommandRead Protocol.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Stratum


/// A protocol indicating its `Content` is readable from stdin.
public protocol CommandReadable {
    
    associatedtype Content
    
}


/// The interface for providing readable content.
public struct CommandReadableContent<Content>: CommandReadable {
    
    internal var contentKey: ContentKey
    
    internal let condition: ((String) throws -> Bool)?
    
    internal let initializer: (String) throws -> Content?
    
    internal let terminator: String
    
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableContent<Bool> { .init(contentKey: .boolean, terminator: " [y/n]: ") { read in
        switch read.lowercased() {
        case "yes", "y":
            return true
        case "no", "n":
            return false
        default:
            return nil
        }
    } }
    
    /// Indicates reading file path to a text file.
    public static var textFile: CommandReadableContent<String> { .init(contentKey: .textFile, terminator: ":\n") { read in
        let filePath = __normalize(filePath: read)
        return try String(contentsOfFile: filePath)
    } }
    
    /// Indicates reading file path.
    public static var filePath: CommandReadableContent<String> { .init(contentKey: .filePath, terminator: ":\n", initializer: __normalize) }
    
    /// Indicates reading string.
    public static var string: CommandReadableContent<String> { .init(contentKey: .string, terminator: ":\n", initializer: { $0 }) }
    
    /// Indicates reading int.
    public static var int: CommandReadableContent<Int> { .init(contentKey: .int, terminator: ": ", initializer: Int.init) }
    
    /// Indicates reading double.
    public static var double: CommandReadableContent<Double> { .init(contentKey: .double, terminator: ": ", initializer: Double.init) }
    
    /// Indicates reading a file path that forms a FinderItem.
    public static var finderItem: CommandReadableContent<FinderItem> { .init(contentKey: .finderItem, terminator: ":\n") { FinderItem(at: __normalize(filePath: $0)) } }
    
    public static func options<Option>(from options: Option) -> CommandReadableContent<Option> where Option: RawRepresentable & CaseIterable, Option.RawValue == String { .init(contentKey: .options, terminator: ": ") { read in
        guard let option = Option(rawValue: read) else { throw ReadError(reason: "Invalid Input: Input not in acceptable set") }
        return option
    } }
    
    
    init(contentKey: ContentKey, terminator: String, condition: ((String) throws -> Bool)? = nil, initializer: @escaping (String) throws -> Content?) {
        self.contentKey = contentKey
        self.terminator = terminator
        self.condition = condition
        self.initializer = initializer
    }
    
    
    internal enum ContentKey: String {
        case boolean
        case textFile
        case filePath
        case string
        case int
        case double
        case finderItem
        case options
    }
    
}
