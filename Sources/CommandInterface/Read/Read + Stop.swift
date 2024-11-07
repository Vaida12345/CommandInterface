//
//  Read + Stop.swift
//  CommandInterface
//
//  Created by Vaida on 8/21/24.
//


/// A ``CommandReadable`` that accepts stop sequence.
public struct CommandReadableStopable<Base>: CommandReadable where Base: CommandReadable {
    
    let base: Base
    
    let stopSequence: [Regex<Substring>]
    
    
    public func transform(input: String) throws -> Base.Content? {
        try base.transform(input: input)
    }
    
    public func condition(content: Base.Content) throws -> Bool {
        try base.condition(content: content)
    }
    
    public func formatter(content: Base.Content) -> String {
        base.formatter(content: content)
    }
    
    public func makeInputReader(configuration: CommandInputReader.Configuration) -> Base.InputReader {
        base.makeInputReader(configuration: CommandInputReader.Configuration(stopSequence: stopSequence))
    }
    
    public typealias Content = Base.Content
    
}


extension CommandReadable {
    
    /// Provides the stop sequence.
    ///
    /// Inputs with stop sequences stops immediately when matched. This would usually indicate that a newline is not inserted. For example
    ///
    /// ```swift
    /// let input = self.read(.string.stopSequence(/\?/), prompt: "read: ")
    /// print(">>>> \(input)")
    /// // read: ?>>>?\n
    /// ```
    ///
    /// - Parameters:
    ///   - sequence: A sequence of `String`s that halts input processing and returns when the entire input matches any element in the sequence.
    public func stopSequence(_ sequence: [Regex<Substring>]) -> CommandReadableStopable<Self> {
        CommandReadableStopable(base: self, stopSequence: sequence)
    }
    
    /// Provides the stop sequence.
    ///
    /// Inputs with stop sequences stops immediately when matched. This would usually indicate that a newline is not inserted. For example
    ///
    /// ```swift
    /// let input = self.read(.string.stopSequence(/\?/), prompt: "read: ")
    /// print(">>>> \(input)")
    /// // read: ?>>>?\n
    /// ```
    ///
    /// - Parameters:
    ///   - sequence: A sequence of `String`s that halts input processing and returns when the entire input matches any element in the sequence.
    public func stopSequence(_ sequence: Regex<Substring>...) -> CommandReadableStopable<Self> {
        self.stopSequence(sequence)
    }
    
}


extension CommandReadableStopable: CommandReadableDefaultable where Base: CommandReadableDefaultable {
    
    /// Provides the default value.
    public func `default`(_ content: Content) -> DefaultedContent {
        DefaultedContent(base: self.base.default(content), stopSequence: self.stopSequence)
    }
    
    public typealias DefaultedContent = CommandReadableStopable<Base.DefaultedContent>
    
}
