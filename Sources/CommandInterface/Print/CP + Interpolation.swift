//
//  CP + Interpolation.swift
//  The Command Interface Module
//
//  Created by Vaida on 4/13/24.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation
import Stratum
import SwiftUI
import OSLog


extension CommandPrintManager {
    
    public struct Interpolation: StringInterpolationProtocol, CustomStringConvertible, TextOutputStream, ExpressibleByStringInterpolation {
        
        var words: [Word]
        
        public var description: String {
            let interpolation = getInterpolation()
            return interpolation.words.reduce("") { $0 + $1.modifier.modify($1.content) }
        }
        
        public func getInterpolation() -> Interpolation {
            let string = self.words.reduce("") { $0 + $1.modifier.modify($1.content) }
            do {
                let parsedContent = try AttributedString(markdown: string, options: .init(interpretedSyntax: .inlineOnly, failurePolicy: .returnPartiallyParsedIfPossible))
                var interpolation = CommandPrintManager.Interpolation(literalCapacity: 0, interpolationCount: 1)
                interpolation.appendInterpolation(parsedContent)
                
                return interpolation
            } catch {
                let logger = Logger(subsystem: "CommandInterface", category: "Markdown Parsing")
                logger.error("\(#function) cannot parse markdown: \"\(string)\". It will not be treated as markdown.")
                return self
            }
        }
        
        public func getRaw() -> String {
            let string = self.words.reduce("") { $0 + $1.content }
            var cumulative = ""
            cumulative.reserveCapacity(string.count)
            var index = string.startIndex
            var isOpened = false
            
            while index < string.endIndex {
                let char = string[index]
                if char == Terminal.escape {
                    isOpened = true
                } else if isOpened && char == "m" {
                    isOpened = false
                } else if !isOpened {
                    cumulative.append(char)
                }
                
                string.formIndex(after: &index)
            }
            
            return cumulative
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
        
        public mutating func appendInterpolation<T>(_ value: T, modifier: CommandPrintManager.Modifier...) {
            self.appendInterpolation(value)
            self.words[words.count - 1].modifier.formUnion(modifier.reduce(into: CommandPrintManager.Modifier.default) { $0.formUnion($1) })
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
                
                if let foregroundColor = attributes.foregroundColor {
                    switch foregroundColor {
                    case .black:     modifier.formUnion(.foregroundColor(.black))
                    case .red:       modifier.formUnion(.foregroundColor(.red))
                    case .green:     modifier.formUnion(.foregroundColor(.green))
                    case .yellow:    modifier.formUnion(.foregroundColor(.yellow))
                    case .blue:      modifier.formUnion(.foregroundColor(.blue))
                    case .cyan:      modifier.formUnion(.foregroundColor(.cyan))
                    case .white:     modifier.formUnion(.foregroundColor(.white))
                    case .primary:   modifier.formUnion(.foregroundColor(.black))
                    case .secondary: modifier.formUnion(.dim)
                    case .gray:      modifier.formUnion(.dim)
                    default:
                        let vector = foregroundColor.animatableData
                        modifier.formUnion(.foregroundColor(.rgb(UInt8(vector[0] * 256), UInt8(vector[1] * 256), UInt8(vector[2] * 256))))
                    }
                }
                
                if let backgroundColor = attributes.backgroundColor {
                    switch backgroundColor {
                    case .black:     modifier.formUnion(.backgroundColor(.black))
                    case .red:       modifier.formUnion(.backgroundColor(.red))
                    case .green:     modifier.formUnion(.backgroundColor(.green))
                    case .yellow:    modifier.formUnion(.backgroundColor(.yellow))
                    case .blue:      modifier.formUnion(.backgroundColor(.blue))
                    case .cyan:      modifier.formUnion(.backgroundColor(.cyan))
                    case .white:     modifier.formUnion(.backgroundColor(.white))
                    case .primary:   modifier.formUnion(.backgroundColor(.black))
                    default:
                        let vector = backgroundColor.animatableData
                        modifier.formUnion(.backgroundColor(.rgb(UInt8(vector[0] * 256), UInt8(vector[1] * 256), UInt8(vector[2] * 256))))
                    }
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
