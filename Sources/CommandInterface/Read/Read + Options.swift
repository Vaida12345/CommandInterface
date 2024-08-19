//
//  Read + Options.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//


public struct CommandReadableOptions<Content>: CommandReadable where Content: RawRepresentable & CaseIterable, Content.RawValue == String {
    
    public func transform(input: String) throws -> Content? {
        Content(rawValue: input)
    }
    
    
    public var defaultValue: Content?
    
}


//extension CommandReadable where Self == CommandReadableOptions<Self.Content> {
//    
//    
//    
//}
