//
//  Cursor.swift
//
//
//  Created by Vaida on 6/7/24.
//

import Foundation
import CICComponent
import RegexBuilder


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
    public static func currentPosition() -> (line: Int, column: Int) {
        write(STDOUT_FILENO, "\(Terminal.escape)[6n", 4)
        
        var buffer = ""
        
        var char: UInt8 = 0
        while char != Character("R").asciiValue! {
            read(STDIN_FILENO, &char, 1)
            buffer.append(Character(UnicodeScalar(char)))
        }
        
        let regex = Regex {
            "\u{1B}["
            
            Capture {
                /\d+/
            } transform: {
                Int($0)!
            }
            
            ";"
            
            Capture {
                /\d+/
            } transform: {
                Int($0)!
            }
            
            "R"
        }
        
        let match = try! regex.wholeMatch(in: buffer)!
        return (match.output.1, match.output.2)
    }
    
    /// Note that line and column starts with `1`.
    @inlinable
    public static func moveTo(line: Int, column: Int) {
        print("\(escape)[\(line);\(column)f", terminator: "")
        fflush(stdout);
    }
    
    /// Move up, and to the beginning of the line.
    @inlinable
    public static func moveUp(line: Int) {
        if line < 0 {
            self.moveDown(line: abs(line))
        } else if line > 0 {
            print("\(escape)[\(line)F", terminator: "")
            fflush(stdout);
        }
    }
    
    // Move up, and to the beginning of the line.
    @inlinable
    public static func moveDown(line: Int) {
        if line < 0 {
            self.moveUp(line: abs(line))
        } else if line > 0 {
            print("\(escape)[\(line)E", terminator: "")
            fflush(stdout);
        }
    }
    
}
