//
//  CommandPrint Modifier.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


extension CommandPrintManager {
    
    /// The modifier to the output.
    public struct Modifier {
        
        /// The internal rawValue.
        private let rawValue: UInt8
        
        private var foregroundColor: Color
        
        private var backgroundColor: Color
        
        private var escaper: String {
            var lhs: Array<Int> = [] // Use array instead of set as 256 color requires order.
            for shift in 0...7 {
                if (self.contains(Modifier(rawValue: 1 << shift))) {
                    lhs.append(__escaper(shift))
                }
            }
            
            if self.foregroundColor != .none {
                if let code = self.foregroundColor.__256ColorCode {
                    lhs.append(contentsOf: [38, 5, code])
                } else {
                    lhs.append(Int(self.foregroundColor.rawValue))
                }
            }
            if self.backgroundColor != .none {
                if let code = self.backgroundColor.__256ColorCode {
                    lhs.append(contentsOf: [48, 5, code])
                } else {
                    lhs.append(Int(self.backgroundColor.rawValue))
                }
            }
            
            return (lhs.unique().map(String.init).joined(separator: ";"))
        }
        
        
        /// The bold modifier.
        private static let bold          = Modifier(rawValue: 1 << 0)
        
        /// The dim / faint modifier.
        private static let dim           = Modifier(rawValue: 1 << 1)
        
        /// The italic modifier.
        private static let italic        = Modifier(rawValue: 1 << 2)
        
        /// The underline modifier.
        private static let underline     = Modifier(rawValue: 1 << 3)
        
        /// The blinking modifier.
        private static let blinking      = Modifier(rawValue: 1 << 4)
        
        /// The inverse modifier.
        private static let inverse       = Modifier(rawValue: 1 << 5)
        
        /// The hidden modifier.
        private static let hidden        = Modifier(rawValue: 1 << 6)
        
        /// The strikethrough modifier.
        private static let strikethrough = Modifier(rawValue: 1 << 7)
        
        /// The default modifier, without any style.
        internal static let `default`    = Modifier(rawValue: 0 << 0)
        
        
        private func __escaper(_ __index: Int) -> Int {
            __index < 5 ? 1 + __index : 2 + __index
        }
        
        /// The bold modifier.
        public func bold() -> Modifier {
            self.union(.bold)
        }
        
        /// The italic modifier.
        public func italic() -> Modifier {
            self.union(.italic)
        }
        
        /// The dim modifier.
        public func dim() -> Modifier {
            self.union(.dim)
        }
        
        /// The underline modifier.
        public func underline() -> Modifier {
            self.union(.underline)
        }
        
        /// The blinking modifier.
        public func blinking() -> Modifier {
            self.union(.blinking)
        }
        
        /// The inverse modifier.
        public func inverse() -> Modifier {
            self.union(.inverse)
        }
        
        /// The hidden modifier.
        public func hidden() -> Modifier {
            self.union(.hidden)
        }
        
        /// The strikethrough modifier.
        ///
        /// - Experiment: This is not supported in Mac Terminal.
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
        
        
        private func union(_ other: Modifier) -> Modifier {
            Modifier(rawValue: self.rawValue | other.rawValue)
        }
        
        private func contains(_ other: Modifier) -> Bool {
            other.rawValue & self.rawValue == other.rawValue
        }
        
        internal func modify(_ content: String) -> String {
            let escapers = self.escaper
            return "\u{1B}[\(escapers)m" + content + "\u{1B}[0m"
        }
        
        private init(rawValue: UInt8, foregroundColor: Color = .none, backgroundColor: Color = .none) {
            self.rawValue = rawValue
            self.foregroundColor = foregroundColor
            self.backgroundColor = backgroundColor
        }
        
    }
    
}


private extension Collection {
    
    /// Removes the repeated elements of an array, leaving only the entries different from each other.
    ///
    /// **Example**
    ///
    /// ```swift
    /// [1, 2, 3, 1].unique() // [1, 2, 3]
    /// ```
    ///
    /// - Returns: The array without repeated elements.
    ///
    /// - Complexity: O(*n*), where *n* is the length of this sequence.
    func unique() -> [Element] where Element: Hashable {
        var container: Set<Element> = []
        var result: [Element] = []
        self.forEach { element in
            guard container.insert(element).inserted else { return }
            result.append(element)
        }
        return result
    }
    
}
