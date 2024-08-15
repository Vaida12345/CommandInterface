//
//  CP + Interpolation.swift
//  The Command Interface Module
//
//  Created by Vaida on 4/13/24.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation
import Stratum


extension CommandPrintManager {
    
    public struct Interpolation: StringInterpolationProtocol, CustomStringConvertible, TextOutputStream, ExpressibleByStringInterpolation {
        
        var words: [Word]
        
        public var description: String {
            self.words.reduce("") { $0 + $1.modifier.modify($1.content) }
        }
        
        public init(literalCapacity: Int, interpolationCount: Int) {
            self.words = []
            self.words.reserveCapacity(literalCapacity + interpolationCount)
        }
        
        public init(stringInterpolation: Interpolation) {
            self = stringInterpolation
        }
        
        public init(stringLiteral value: String) {
            self.words = [Word(content: value, modifier: .default)]
        }
        
        private mutating func _append(string: String, modifier: Modifier) {
            self.words.append(Word(content: string, modifier: modifier))
        }
        
        public mutating func appendLiteral(_ literal: String) {
            self._append(string: literal, modifier: .default)
        }
        
        public mutating func appendInterpolation<T>(_ value: T) where T: CustomStringConvertible {
            self._append(string: value.description, modifier: .default)
        }
        
        public mutating func appendInterpolation(_ value: Interpolation) {
            self.words.append(contentsOf: value.words)
        }
        
        public mutating func appendInterpolation<T>(_ value: T) {
            switch T.self {
            case is FinderItem.Type:
                self.appendInterpolation(value as! FinderItem)
            case is AttributedString.Type:
                self.appendInterpolation(value as! AttributedString)
                
            default:
                self.appendLiteral("\(value)")
            }
        }
        
        public mutating func appendInterpolation(_ value: FinderItem) {
            self.appendInterpolation(value.path, modifier: .underline.foregroundColor(.blue))
        }
        
        public mutating func appendInterpolation<T>(_ value: T, modifier: CommandPrintManager.Modifier) {
            self.appendInterpolation(value)
            self.words[words.count - 1].modifier.formUnion(modifier)
        }
        
        public mutating func appendInterpolation<T>(_ value: T, modifiers: CommandPrintManager.Modifier...) {
            self.appendInterpolation(value, modifier: modifiers.reduce(into: CommandPrintManager.Modifier.default) { $0.formUnion($1) })
        }
        
        public mutating func appendInterpolation(_ value: AttributedString) {
            for run in value.runs {
                let range = run.range
                let raw = value[range].characters
                let attributes = run.attributes
                var modifier = CommandPrintManager.Modifier.default
                
                // check attributes
                if let intend = attributes.inlinePresentationIntent {
                    
                    if intend.contains(.emphasized)         { modifier.formUnion(.italic) }
                    if intend.contains(.strikethrough)      { modifier.formUnion(.strikethrough) }
                    if intend.contains(.stronglyEmphasized) { modifier.formUnion(.bold) }
                }
                
                self.appendInterpolation(String(raw), modifier: modifier)
            }
        }
        
        public mutating func write(_ string: String) {
            self.appendLiteral(string)
        }
        
        public typealias StringLiteralType = String
        
        public typealias StringInterpolation = Self
        
        struct Word {
            
            let content: String
            
            var modifier: Modifier
            
        }
        
    }
    
}
