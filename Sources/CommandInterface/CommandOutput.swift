//
//  CommandOutput.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


/// The interface for interacting with stdout.
public struct CommandOutput {
    
    /// Ring the terminal bell, which is typically used for alert.
    ///
    /// ```swift
    /// self.output.bell()
    ///
    /// // no output, the terminal would flash to indicate error.
    /// ```
    func bell() {
        print("\u{7}", terminator: "")
    }
    
    /// Reset the position of the cursor to the beginning of the current line.
    ///
    /// The cursor is moved to the left-most position on the current line, effectively "overwriting" any characters that were previously displayed on that line.
    ///
    /// ```swift
    /// print("abc")
    /// self.output.carriageReturn()
    /// print(123)
    ///
    /// // output is 123.
    /// ```
    func carriageReturn() {
        print("\u{13}", terminator: "")
    }
    
    /// Erase entire screen.
    func clear() {
        print("\u{001B}[2J", terminator: "")
    }
    
}
