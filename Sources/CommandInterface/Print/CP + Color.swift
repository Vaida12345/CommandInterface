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
        
        case black = 30
        case red = 31
        case green = 32
        case yellow = 33
        case blue = 34
        case magenta = 35
        case cyan = 36
        case white = 37
        case `default` = 38
        
        case brightBlack = 90
        case brightRed = 91
        case brightGreen = 92
        case brightYellow = 93
        case brightBlue = 94
        case brightMagenta = 95
        case brightCyan = 96
        case brightWhite = 97
        
        // Stand alone colors
        
//        /// A gray color with color ID 245.
//        case secondary = -1
        
        
//        internal var __256ColorCode: Int? {
//            switch self.rawValue {
//            case -1:
//                return 245
//            default:
//                return nil
//            }
//        }
    }
    
}
