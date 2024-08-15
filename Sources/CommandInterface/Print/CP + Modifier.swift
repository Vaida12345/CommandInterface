//
//  CommandPrint Modifier.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


extension CommandPrintManager {
    
    /// The modifier to the output.
    public struct Modifier: OptionSet, Sendable {
        
        /// The internal rawValue.
        ///
        /// Layout
        /// ```
        /// |    <- 8 bit ->   |    <- 8 bit ->   |    ...   |
        /// | foreground color | background color | raw bits |
        /// ```
        public let rawValue: UInt64
        
        public var foregroundColor: Color? {
            let bits = self.rawValue >> (64 - 8)
            return Color(rawValue: UInt8(truncatingIfNeeded: bits))
        }
        
        public var backgroundColor: Color? {
            let bits = self.rawValue >> (64 - 16)
            return Color(rawValue: UInt8(truncatingIfNeeded: bits))
        }
        
        private var escaper: String {
            var lhs: Array<Int> = [] // Use array instead of set as 256 color requires order.
            for shift in 1...9 {
                if (self.contains(Modifier(rawValue: 1 << shift))) {
                    lhs.append(shift)
                }
            }
            
            if let raw = self.foregroundColor?.rawValue {
                lhs.append(Int(raw))
            }
            if let raw = self.backgroundColor?.rawValue {
                lhs.append(Int(raw) + 10)
            }
            
            return (lhs.unique().map(String.init).joined(separator: ";"))
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
        /// Note: This mode is not supported on the macOS native terminal.
        public static let strikethrough = Modifier(rawValue: 1 << 9)
        
        /// The default modifier, without any style.
        public static let `default`    = Modifier(rawValue: 0 << 0)
        
        
        private func __escaper(_ __index: Int) -> Int {
            __index < 5 ? 1 + __index : 2 + __index
        }
        
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
            Modifier(rawValue: self.rawValue, foregroundColor: color, backgroundColor: self.backgroundColor)
        }
        
        /// Sets the text background color.
        public func backgroundColor(_ color: Color) -> Modifier {
            Modifier(rawValue: self.rawValue, foregroundColor: self.foregroundColor, backgroundColor: color)
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
            let escapers = self.escaper
            return "\u{1B}[\(escapers)m" + content + "\u{1B}[0m"
        }
        
        private init(rawValue: UInt64, foregroundColor: Color? = nil, backgroundColor: Color? = nil) {
            var rawValue = rawValue
            rawValue |= UInt64(foregroundColor?.rawValue ?? UInt8()) << (64 - 8)
            rawValue |= UInt64(backgroundColor?.rawValue ?? UInt8()) << (64 - 16)
            
            self.rawValue = rawValue
        }
        
        public init(rawValue: UInt64) {
            self.init(rawValue: rawValue, foregroundColor: nil, backgroundColor: nil)
        }
    }
    
}
