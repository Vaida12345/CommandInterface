//
//  Raw Input.swift
//
//
//  Created by Vaida on 6/7/24.
//

import Foundation


/// Consume and returns next char.
///
/// You need to ensure the Terminal is in raw mode by ``Terminal/setRawMode()``
///
/// - Note: You need to `fflush` to push output.
@available(*, deprecated, renamed: "NextChar.consumeNext()")
public func __consumeNext() -> NextChar? {
    NextChar.consumeNext()
}


// Function to set the terminal to raw mode
@available(*, deprecated, renamed: "Terminal.setRawMode()", message: "Use the public interface instead.")
@inlinable
public func __setRawMode() -> termios {
    fflush(stdout)
    
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
    
    return originalTerm
}

// Function to reset the terminal to its original settings
@available(*, deprecated, renamed: "Terminal.reset()", message: "Use the public interface instead.")
@inlinable
public func __resetTerminal(originalTerm: inout termios) {
    tcsetattr(STDIN_FILENO, TCSANOW, &originalTerm)
}

