//
//  CommandRead Protocol.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


/// A protocol indicating its `Content` is readable from stdin.
public protocol CommandReadable {
    
    associatedtype Content
    
}


/// The interface for providing readable content.
public struct CommandReadableContent<Content>: CommandReadable {
    
    internal var contentKey: ContentKey
    
    /// Indicates reading boolean value.
    public static var bool: CommandReadableContent<Bool> { .init(contentKey: .boolean) }
    
    public static var textFile: CommandReadableContent<String> { .init(contentKey: .textFile) }
    
    public static var filePath: CommandReadableContent<String> { .init(contentKey: .filePath) }
    
    public static var string: CommandReadableContent<String> { .init(contentKey: .string) }
    
    public static var int: CommandReadableContent<Int> { .init(contentKey: .int) }
    
    public static var double: CommandReadableContent<Double> { .init(contentKey: .double) }
    
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
    }
    
}
