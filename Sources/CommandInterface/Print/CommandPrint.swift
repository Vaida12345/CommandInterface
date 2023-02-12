//
//  CommandPrint.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import Darwin
import CHelpers


/// The interface for interacting with printing to stdout.
public struct CommandPrintManager {
    
    /// Writes any buffered data to stdout.
    ///
    /// - Returns: A boolean value indicating if the action succeed.
    @discardableResult public func flush() -> Bool {
        fflush(stdout) != 0
    }
    
    /// Prints progress bar given the value.
    ///
    /// To make the progress bar increases properly, please make sure no value is printed between two calls.
    public func progress(value: Double) {
        let size = __getTerminalSize()
        let total = Int(size.ws_col - 2)
        let completed = Int(Double(total) * value)
        
        let value = "[" + String(repeating: "=", count: completed) + String(repeating: " ", count: total - completed) + "]"
        print(value, terminator: "\r")
    }
    
}
