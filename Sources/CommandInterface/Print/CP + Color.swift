//
//  CommandPrint Color.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


extension CommandPrintManager {
    
    /// The system defined colors.
    public class Color: Equatable, @unchecked Sendable {
        
        let code: UInt8
        
        required init(code: UInt8) {
            self.code = code
        }
        
        public static let black   = _8Color(code: 30)
        public static let red     = _8Color(code: 31)
        public static let green   = _8Color(code: 32)
        public static let yellow  = _8Color(code: 33)
        public static let blue    = _8Color(code: 34)
        public static let magenta = _8Color(code: 35)
        public static let cyan    = _8Color(code: 36)
        public static let white   = _8Color(code: 37)
        
        public static let `default` = Color(code: 39)
        
        /// A RGB color.
        ///
        /// As macOS native Terminal only supports 256-color mode, the RGB spectrum is divided into a 6x6x6 cube.
        public static func rgb(_ r: UInt8, _ g: UInt8, _ b: UInt8) -> _256Color {
            _256Color(red: r, green: g, blue: b)
        }
        
        
        public static func == (_ lhs: Color, _ rhs: Color) -> Bool {
            lhs.code == rhs.code
        }
        
    }
    
    public class _8Color: Color, @unchecked Sendable {
        
        public var bright: _Bright8Color {
            _Bright8Color(code: self.code + 60)
        }
        
    }
    
    public final class _Bright8Color: _8Color, @unchecked Sendable {
        
    }
    
    public final class _256Color: Color, @unchecked Sendable {
        
        convenience init(red r: UInt8, green g: UInt8, blue b: UInt8) {
            // Normalize the RGB values to a 6x6x6 color cube
            let r = UInt8(Double(r) / 255 * 5)
            let g = UInt8(Double(g) / 255 * 5)
            let b = UInt8(Double(b) / 255 * 5)
            
            // Calculate the 256-color code
            self.init(code: 16 + (36 * r) + (6 * g) + b)
        }
        
    }
    
}
