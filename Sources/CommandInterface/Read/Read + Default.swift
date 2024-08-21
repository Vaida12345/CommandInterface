//
//  Read + Default.swift
//  CommandInterface
//
//  Created by Vaida on 8/21/24.
//


/// A ``CommandReadable`` that accepts default value.
public protocol CommandReadableDefaultable: CommandReadable {
    
    /// Returns self with the given default value
    func `default`(_ defaultValue: Content) -> DefaultedContent
    
    associatedtype DefaultedContent: CommandReadableDefaultable
    
}
