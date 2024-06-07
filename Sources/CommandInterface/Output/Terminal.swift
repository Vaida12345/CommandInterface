//
//  Terminal.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation


/// The interface for interacting with stdout.
public struct Terminal {
    
    public static var cursor: Cursor.Type {
        Cursor.self
    }
    
    /// - SeeAlso: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
    static let escape = "\u{001B}"
    
    /// Ring the terminal bell, which is typically used for alert.
    ///
    /// ```swift
    /// self.output.bell()
    ///
    /// // no output, the terminal would flash to indicate error.
    /// ```
    public static func bell() {
        print("\u{7}", terminator: "")
    }
    
    /// Clear the current line on which the cursor is on.
    ///
    /// ```swift
    /// print("hdsuaidhsaiudhsuaidhsauihdsaui", terminator: "")
    /// self.output.clearLine()
    /// print(12)
    ///
    /// // output is 12
    /// ```
    public static func clearLine() {
        print("\(escape)[2K", terminator: "")
        print("\(escape)[0G", terminator: "")
    }
    
    /// Clear the previous line on which the cursor is on.
    ///
    /// ```swift
    /// print("hdsuaidhsaiudhsuaidhsauihdsaui")
    /// self.output.clearLastLine()
    /// print(12)
    ///
    /// // output is 12, the first line is erased
    /// ```
    public static func clearLastLine() {
        print("\(escape)[1F", terminator: "") // one line up, to beginning
        print("\(escape)[0K", terminator: "") // erase til end of line
        print("\(escape)[0G", terminator: "") // reset cursor
    }
    
    /// Erase entire screen.
    public static func clearScreen() {
        print("\(escape)[2J", terminator: "")
        Cursor.moveToHome()
    }
    
    public static func eraseFromCursorToEndOfLine() {
        print("\(escape)[0K", terminator: "")
    }
    
    public static func eraseFromStartOfLineToCursor() {
        print("\(escape)[1K", terminator: "")
    }
    
    public static func insertAtCursor(_ value: String) {
        print("\(escape)[@\(value)", terminator: "")
    }
    
}
