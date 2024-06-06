//
//  CommandOutput.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation


fileprivate let escape = "\u{001B}"


/// The interface for interacting with stdout.
public struct CommandOutputManager {
    
    /// Ring the terminal bell, which is typically used for alert.
    ///
    /// ```swift
    /// self.output.bell()
    ///
    /// // no output, the terminal would flash to indicate error.
    /// ```
    public func bell() {
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
    public func clearLine() {
        print("\(escape)[1K", terminator: "")
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
    public func clearLastLine() {
        print("\(escape)[1F", terminator: "") // one line up, to beginning
        print("\(escape)[0K", terminator: "") // erase til end of line
        print("\(escape)[0G", terminator: "") // reset cursor
    }
    
    /// Erase entire screen.
    public func clearScreen() {
        print("\(escape)[2J", terminator: "")
        self.moveToHome()
    }
    
    /// moves cursor to home position (0, 0)
    public func moveToHome() {
        print("\(escape)[H", terminator: "")
    }
    
    /// moves cursor to column `toColumn` within the same line.
    ///
    /// ```swift
    /// print("abc")
    /// self.output.moveCursor()
    /// print(1)
    ///
    /// // output is 1bc.
    /// ```
    public func moveCursor(toColumn: Int = 0) {
        print("\(escape)[\(toColumn)G", terminator: "")
    }
    
    public func moveCursor(toRight: Int) {
        if toRight > 0 {
            print("\(escape)[\(toRight)C", terminator: "")
        } else if toRight < 0 {
            print("\(escape)[\(abs(toRight))D", terminator: "")
        }
    }
    
    public func eraseFromCursorToEndOfLine() {
        print("\(escape)[0K", terminator: "")
    }
    
    public func eraseAtCursorPosition() {
        print("\(escape)[P", terminator: "")
    }
    
    public func insertAtCursor(_ value: String) {
        print("\(escape)[@\(value)", terminator: "")
    }
    
}
