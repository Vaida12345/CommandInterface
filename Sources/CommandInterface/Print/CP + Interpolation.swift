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
        
        private var value: String
        
        public var description: String {
            self.value
        }
        
        public init(literalCapacity: Int, interpolationCount: Int) {
            self.value = String()
            self.value.reserveCapacity(literalCapacity)
        }
        
        public init(stringInterpolation: CommandPrintManager.Interpolation) {
            self = stringInterpolation
        }
        
        public init(stringLiteral value: String) {
            self.value = value
        }
        
        
        public mutating func appendLiteral(_ literal: String) {
            self.value += literal
        }
        
        public mutating func appendInterpolation<T>(_ value: T) where T: CustomStringConvertible {
            self.value += value.description
        }
        
        public mutating func appendInterpolation<T>(_ value: T) {
            self.value += String(describing: value)
        }
        
        public mutating func appendInterpolation(_ value: FinderItem) {
            self.appendInterpolation(value.url, modifier: .underline)
        }
        
        public mutating func appendInterpolation<T>(_ value: T, modifier: CommandPrintManager.Modifier) {
            self.value += modifier.modify(String(describing: value))
        }
        
        public mutating func write(_ string: String) {
            self.value += string
        }
        
        public typealias StringLiteralType = String
        
        public typealias StringInterpolation = Self
        
    }
    
}
