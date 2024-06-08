//
//  Cursor.swift
//
//
//  Created by Vaida on 6/7/24.
//

import Foundation
import CICComponent


public struct Cursor {
    
    @inlinable
    public static var escape: Character {
        Terminal.escape
    }
    
    /// moves cursor to home position (0, 0), scrolled to top.
    @inlinable
    public static func moveToHome() {
        print("\(escape)[H", terminator: "")
        fflush(stdout);
    }
    
    /// moves cursor to column `toColumn` within the same line.
    ///
    /// ```swift
    /// print("abc")
    /// Cursor.move(toColumn: 0)
    /// print(1)
    ///
    /// // output is 1bc.
    /// ```
    @inlinable
    public static func move(toColumn: Int) {
        print("\(escape)[\(toColumn)G", terminator: "")
        fflush(stdout);
    }
    
    @inlinable
    public static func move(toRight: Int) {
        if toRight > 0 {
            print("\(escape)[\(toRight)C", terminator: "")
        } else if toRight < 0 {
            print("\(escape)[\(abs(toRight))D", terminator: "")
        }
        fflush(stdout);
    }
    
    @inlinable
    public static func move(toLeft: Int) {
        move(toRight: -toLeft)
    }
    
    
    @inlinable
    static func currentPosition() throws -> (line: Int, column: Int) {
        var x: Int32 = 0
        var y: Int32 = 0
        get_pos(&x, &y)
        return (Int(x), Int(y))
    }
    
    /// Note that line and column starts with `1`.
    @inlinable
    public static func moveTo(line: Int, column: Int) {
        print("\(escape)[\(line);\(column)f", terminator: "")
        fflush(stdout);
    }
    
}
