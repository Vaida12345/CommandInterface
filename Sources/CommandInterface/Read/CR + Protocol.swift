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
    
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableContent<Bool> { .init(contentKey: .boolean) }
    
    /// Indicates reading file path to a text file.
    public static var textFile: CommandReadableContent<String> { .init(contentKey: .textFile) }
    
    /// Indicates reading file path.
    public static var filePath: CommandReadableContent<String> { .init(contentKey: .filePath) }
    
    /// Indicates reading string.
    public static var string: CommandReadableContent<String> { .init(contentKey: .string) }
    
    /// Indicates reading int.
    public static var int: CommandReadableContent<Int> { .init(contentKey: .int) }
    
    /// Indicates reading double.
    public static var double: CommandReadableContent<Double> { .init(contentKey: .double) }
    
    /// Indicates reading a file path that forms a FinderItem.
    public static var finderItem: CommandReadableContent<FinderItem> { .init(contentKey: .finderItem) }
    
    
    private init(contentKey: ContentKey) {
        self.contentKey = contentKey
    }
    
    
    internal enum ContentKey: String {
        case boolean
        case textFile
        case filePath
        case string
        case int
        case double
        case finderItem
    }
    
}
