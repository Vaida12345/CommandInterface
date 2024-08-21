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
    
    nonisolated(unsafe) private static var originalTerminal: termios?
    
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
        print("\(escape)[2K", terminator: "") // erase the entire line
        print("\(escape)[0G", terminator: "") // moves cursor to column 0
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
    public static func eraseFromCursorToEndOfScreen() {
        print("\(escape)[0J", terminator: "")
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
    
    /// Sets the terminal to raw mode.
    ///
    /// Terminal raw mode is a mode in which the terminal operates without processing input or output, meaning it doesn't interpret special characters like `⌃+C` or `⏎` and doesn't echo typed characters back to the screen. This mode allows programs to have full control over user input, which is useful for implementing custom key handling, like in text editors or command-line interfaces.
    public static func setRawMode() {
        fflush(stdout)
        guard self.originalTerminal == nil else { return } // a;ready set
        
        var originalTerm = termios()
        var rawTerm = termios()
        
        // Get the current terminal settings
        tcgetattr(STDIN_FILENO, &originalTerm)
        rawTerm = originalTerm
        
        // Set the terminal to raw mode
        rawTerm.c_lflag &= ~(UInt(ICANON | ECHO))
        rawTerm.c_cc.0 = 1 // VMIN
        rawTerm.c_cc.1 = 0 // VTIME
        
        tcsetattr(STDIN_FILENO, TCSANOW, &rawTerm)
        
        self.originalTerminal = originalTerm
    }
    
    /// Reset the terminal to original mode.
    public static func reset() {
        guard var terminal = self.originalTerminal else { return }
        tcsetattr(STDIN_FILENO, TCSANOW, &terminal)
        self.originalTerminal = nil
    }
    
    static var defaultInterface: DefaultInterface {
        .default
    }
    
    /// The size of current Terminal window.
    @inlinable
    public static func windowSize() -> (width: Int, height: Int)? {
        var w = winsize()
        if ioctl(STDOUT_FILENO, TIOCGWINSZ, &w) == 0 {
            return (width: Int(w.ws_col), height: Int(w.ws_row))
        } else {
            return nil
        }
    }
    
}
