//
//  CommandPrint.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Darwin
import Foundation


/// The interface for interacting with printing to stdout.
public struct CommandPrintManager {
    
    /// Writes any buffered data to stdout.
    ///
    /// - Returns: A boolean value indicating if the action succeed.
    @discardableResult public func flush() -> Bool {
        fflush(stdout) != 0
    }
    
}
