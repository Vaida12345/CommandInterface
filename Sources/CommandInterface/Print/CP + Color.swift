//
//  CommandPrint Color.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


extension CommandPrintManager {
    
    /// The system defined colors.
    public enum Color: UInt8 {
        
        case none = 0
        
        case black = 30
        case red
        case green
        case yellow
        case blue
        case magenta
        case cyan
        case white
        case `default`
        
        case brightBlack = 90
        case brightRed
        case brightGreen
        case brightYellow
        case brightBlue
        case brightMagenta
        case brightCyan
        case brightWhite
        
    }
    
}
