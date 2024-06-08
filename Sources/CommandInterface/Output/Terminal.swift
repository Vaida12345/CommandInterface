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
    
    @inlinable
    public static var cursor: Cursor.Type {
        Cursor.self
    }
    
    /// - SeeAlso: https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
    public static let escape: Character = "\u{001B}"
    
    /// Ring the terminal bell, which is typically used for alert.
    ///
    /// ```swift
    /// self.output.bell()
    ///
    /// // no output, the terminal would flash to indicate error.
    /// ```
    @inlinable
    public static func bell() {
        print("\u{7}", terminator: "")
        fflush(stdout);
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
    @inlinable
    public static func clearLine() {
        print("\(escape)[2K", terminator: "")
        print("\(escape)[0G", terminator: "")
        fflush(stdout);
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
    @inlinable
    public static func clearLastLine() {
        print("\(escape)[1F", terminator: "") // one line up, to beginning
        print("\(escape)[0K", terminator: "") // erase til end of line
        print("\(escape)[0G", terminator: "") // reset cursor
        fflush(stdout);
    }
    
    /// Erase entire screen.
    @inlinable
    public static func clearScreen() {
        print("\(escape)[2J", terminator: "")
        Cursor.moveToHome()
        fflush(stdout);
    }
    
    @inlinable
    public static func eraseFromCursorToEndOfLine() {
        print("\(escape)[0K", terminator: "")
        fflush(stdout);
    }
    
    @inlinable
    public static func eraseFromStartOfLineToCursor() {
        print("\(escape)[1K", terminator: "")
        fflush(stdout);
    }
    
    @inlinable
    public static func insertAtCursor(_ value: String) {
        print("\(escape)[@\(value)", terminator: "")
        fflush(stdout);
    }
    
}
