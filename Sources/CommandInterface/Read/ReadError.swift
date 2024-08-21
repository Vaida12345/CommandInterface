//
//  ReadError.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//

import Foundation
import Stratum


/// The error with a reason for the failure of reading.
public struct ReadError: LocalizedError {
    
    let reason: String
    
    public var errorDescription: String? {
        self.reason
    }
    
    /// Initialize with a reason.
    ///
    /// - Parameters:
    ///   - reason: The reason why an error occurred.
    public init(reason: String) {
        self.reason = reason
    }
    
}
