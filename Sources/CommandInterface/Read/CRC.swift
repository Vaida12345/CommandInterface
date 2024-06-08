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
    
    internal let terminator: String
    
    internal let overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)?
    
    internal let condition: ((Content) throws -> Bool)?
    
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableContent<Bool> { .init(terminator: " [y/n]: ") { read in
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
    public static var textFile: CommandReadableContent<String> { .init(terminator: ":\n") { read in
        let filePath = FinderItem.normalize(shellPath: read)
        return try String(contentsOfFile: filePath)
    } }
    
    /// Indicates reading file path.
    public static var filePath: CommandReadableContent<String> { .init(terminator: ":\n", initializer: { FinderItem.normalize(shellPath: $0) }) }
    
    /// Indicates reading string.
    public static var string: CommandReadableContent<String> { .init(terminator: ":\n", initializer: { $0 }) }
    
    /// Indicates reading int.
    public static var int: CommandReadableContent<Int> { .init(terminator: ": ", initializer: Int.init) }
    
    /// Indicates reading double.
    public static var double: CommandReadableContent<Double> { .init(terminator: ": ", initializer: Double.init) }
    
    /// Indicates reading a file path that forms a FinderItem.
    public static var finderItem: CommandReadableContent<FinderItem> { .init(terminator: ":\n") {
        FinderItem(at: FinderItem.normalize(shellPath: $0))
    } condition: {
        guard $0.exists else { throw ReadError(reason: "Invalid Input: The input filePath does not exist") }
        return true
    } }
    
    public static func customized(initializer: @escaping (String) throws -> Content?) -> CommandReadableContent<Content> {
        .init(terminator: ": ", initializer: initializer)
    }
    
    
    init(terminator: String, initializer: @escaping (String) throws -> Content?, overrideGetLoop: ((_ manager: CommandReadManager<Content>, _ content: CommandReadableContent<Content>) -> Content)? = nil, condition: ((Content) throws -> Bool)? = nil) {
        self.terminator = terminator
        self.initializer = initializer
        self.overrideGetLoop = overrideGetLoop
        self.condition = condition
    }
    
}
