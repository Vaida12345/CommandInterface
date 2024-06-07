//
//  CommandPrint Modifier.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


extension CommandPrintManager {
    
    /// The modifier to the output.
    public struct Modifier: OptionSet {
        
        /// The internal rawValue.
        public let rawValue: UInt8
        
        private var foregroundColor: Color?
        
        private var backgroundColor: Color?
        
        private var escaper: String {
            var lhs: Array<Int> = [] // Use array instead of set as 256 color requires order.
            for shift in 0...7 {
                if (self.contains(Modifier(rawValue: 1 << shift))) {
                    lhs.append(__escaper(shift))
                }
            }
            
            if let raw = self.foregroundColor?.rawValue {
                lhs.append(Int(raw))
            }
            if let raw = self.backgroundColor?.rawValue{
                lhs.append(Int(raw) + 10)
            }
            
            return (lhs.unique().map(String.init).joined(separator: ";"))
        }
        
        
        /// The bold modifier.
        public static let bold          = Modifier(rawValue: 1 << 0)
        
        /// The dim / faint modifier.
        public static let dim           = Modifier(rawValue: 1 << 1)
        
        /// The italic modifier.
        public static let italic        = Modifier(rawValue: 1 << 2)
        
        /// The underline modifier.
        public static let underline     = Modifier(rawValue: 1 << 3)
        
        /// The blinking modifier.
        public static let blinking      = Modifier(rawValue: 1 << 4)
        
        /// The inverse modifier.
        public static let inverse       = Modifier(rawValue: 1 << 5)
        
        /// The hidden modifier.
        public static let hidden        = Modifier(rawValue: 1 << 6)
        
        /// The strikethrough modifier.
        public static let strikethrough = Modifier(rawValue: 1 << 7)
        
        /// The default modifier, without any style.
        internal static let `default`    = Modifier(rawValue: 0 << 0)
        
        
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
            let escapers = self.escaper
            return "\u{1B}[\(escapers)m" + content + "\u{1B}[0m"
        }
        
        private init(rawValue: UInt8, foregroundColor: Color? = nil, backgroundColor: Color? = nil) {
            self.rawValue = rawValue
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
        }
        
        public init(rawValue: UInt8) {
            self.init(rawValue: rawValue, foregroundColor: nil, backgroundColor: nil)
        }
    }
    
}
