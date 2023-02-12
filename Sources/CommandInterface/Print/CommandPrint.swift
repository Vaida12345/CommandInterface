//
//  CommandPrint.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import Darwin


/// The interface for interacting with printing to stdout.
public struct CommandPrintManager {
    
    /// write any buffered data to stdout.
    ///
    /// - Returns: A boolean value indicating if the action succeed.
    @discardableResult func flush() -> Bool {
        fflush(stdout) != 0
    }
    
}
