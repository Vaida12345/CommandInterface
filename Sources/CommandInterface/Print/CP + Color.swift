//
//  CommandPrint Color.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


extension CommandPrintManager {
    
    /// The system defined colors.
    public enum Color: Int8 {
        
        case none = 0
        
        case black = 30
        case red = 31
        case green
        case yellow
        case blue
        case magenta
        case cyan
        case white
        case `default`
        
        case brightBlack = 90
        case brightRed = 91
        case brightGreen
        case brightYellow
        case brightBlue
        case brightMagenta
        case brightCyan
        case brightWhite
        
        // Stand alone colors
        
        /// A gray color with color ID 245.
        case secondary = -1
        
        
        internal var __256ColorCode: Int? {
            switch self.rawValue {
            case -1:
                return 245
            default:
                return Int(self.rawValue)
            }
        }
    }
    
}
