//
//  CommandPrint Modifier.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


extension CommandPrintManager {
    
    /// The modifier to the output.
    public struct Modifier: Sendable, Equatable {
        
        /// The internal rawValue.
        private var options: Options
        
        public var foregroundColor: Color?
        
        public var backgroundColor: Color?
        
        
        public func contains(_ rhs: Modifier) -> Bool {
            guard self.options.contains(rhs.options) else { return false }
            guard self.foregroundColor == nil || self.foregroundColor == rhs.foregroundColor else { return false }
            guard self.backgroundColor == nil || self.backgroundColor == rhs.backgroundColor else { return false }
            return true
        }
        
        public func union(_ rhs: Modifier) -> Modifier {
            Modifier(
                options: self.options.union(rhs.options),
                foregroundColor: self.foregroundColor ?? rhs.foregroundColor,
                backgroundColor: self.backgroundColor ?? rhs.backgroundColor
            )
        }
        
        public mutating func formUnion(_ rhs: Modifier) {
            self.options.formUnion(rhs.options)
            if self.foregroundColor == nil { self.foregroundColor = rhs.foregroundColor }
            if self.backgroundColor == nil { self.backgroundColor = rhs.backgroundColor }
        }
        
        
        /// The bold modifier.
        public static let bold          = Modifier(rawValue: 1 << 1)
        
        /// The dim / faint modifier.
        public static let dim           = Modifier(rawValue: 1 << 2)
        
        /// The italic modifier.
        public static let italic        = Modifier(rawValue: 1 << 3)
        
        /// The underline modifier.
        public static let underline     = Modifier(rawValue: 1 << 4)
        
        /// The blinking modifier.
        public static let blinking      = Modifier(rawValue: 1 << 5)
        
        /// The inverse / reverse modifier.
        public static let inverse       = Modifier(rawValue: 1 << 7)
        
        /// The hidden / invisible modifier.
        public static let hidden        = Modifier(rawValue: 1 << 8)
        
        /// The strikethrough modifier.
        ///
        /// - Note: This mode is not supported on the macOS native terminal.
        public static let strikethrough = Modifier(rawValue: 1 << 9)
        
        /// The default modifier, without any style.
        public static let `default`     = Modifier(rawValue: 0 << 0)
        
        
        /// The bold modifier.
        @inlinable
        public func bold() -> Modifier {
            self.union(.bold)
        }
        
        /// The italic modifier.
        @inlinable
        public func italic() -> Modifier {
            self.union(.italic)
        }
        
        /// The dim modifier.
        @inlinable
        public func dim() -> Modifier {
            self.union(.dim)
        }
        
        /// The underline modifier.
        @inlinable
        public func underline() -> Modifier {
            self.union(.underline)
        }
        
        /// The blinking modifier.
        @inlinable
        public func blinking() -> Modifier {
            self.union(.blinking)
        }
        
        /// The inverse modifier.
        @inlinable
        public func inverse() -> Modifier {
            self.union(.inverse)
        }
        
        /// The hidden modifier.
        @inlinable
        public func hidden() -> Modifier {
            self.union(.hidden)
        }
        
        /// The strikethrough modifier.
        ///
        /// - Experiment: This is not supported in Mac Terminal.
        @inlinable
        public func strikethrough() -> Modifier {
            self.union(.strikethrough)
        }
        
        /// Sets the text color.
        public func foregroundColor(_ color: Color) -> Modifier {
            Modifier(options: self.options, foregroundColor: color, backgroundColor: self.backgroundColor)
        }
        
        /// Sets the text background color.
        public func backgroundColor(_ color: Color) -> Modifier {
            Modifier(options: self.options, foregroundColor: self.foregroundColor, backgroundColor: color)
        }
        
        /// Sets the text color.
        public static func foregroundColor(_ color: Color) -> Modifier {
            Modifier(rawValue: 0, foregroundColor: color)
        }
        
        /// Sets the text background color.
        public static func backgroundColor(_ color: Color) -> Modifier {
            Modifier(rawValue: 0, backgroundColor: color)
        }
        
        internal func modify(_ content: String) -> String {
            guard self != .default else { return content }
            
            var header = ""
            var options: Set<Int> = []
            for shift in 1...9 {
                if (self.options.contains(Options(rawValue: 1 << shift))) {
                    options.insert(shift)
                }
            }
            
            if let foregroundColor = self.foregroundColor {
                if let color = foregroundColor as? _256Color {
                    header += "\u{1B}[38;5;\(color.code)m"
                } else {
                    options.insert(Int(foregroundColor.code))
                }
            }
            
            if let backgroundColor = self.backgroundColor {
                if let color = backgroundColor as? _256Color {
                    header += "\u{1B}[48;5;\(color.code)m"
                } else {
                    options.insert(Int(backgroundColor.code) + 10)
                }
            }
            
            if !options.isEmpty {
                header += "\u{1B}[\(options.map(String.init).joined(separator: ";"))m"
            }
            
            return header + content + "\u{1B}[0m"
        }
        
        private init(rawValue: UInt64, foregroundColor: Color? = nil, backgroundColor: Color? = nil) {
            self.options = Options(rawValue: rawValue)
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
        }
        
        private init(options: Options, foregroundColor: Color? = nil, backgroundColor: Color? = nil) {
            self.options = options
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
        }
        
        public init(rawValue: UInt64) {
            self.init(rawValue: rawValue, foregroundColor: nil, backgroundColor: nil)
        }
        
        public static func == (_ lhs: Self, _ rhs: Self) -> Bool {
            lhs.options == rhs.options &&
            lhs.foregroundColor == rhs.foregroundColor &&
            lhs.backgroundColor == rhs.backgroundColor
        }
        
        
        private struct Options: OptionSet, Sendable, CustomStringConvertible {
            
            var description: String {
                "Options(\(rawValue))"
            }
            
            let rawValue: UInt64
            
        }
    }
    
}
