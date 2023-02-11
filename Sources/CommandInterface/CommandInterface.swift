//
//  CommandInterface.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import CHelpers
import CoreGraphics


/// The protocol whose conforming types serve as entry points.
public protocol CommandInterface {
    
    /// The entry point.
    func main() async throws
    
    /// The initializer of your structure.
    ///
    /// Typically this initializer does not require implementation, as Swift would do it for you.
    init()
    
}


public extension CommandInterface {
    
    static func main() async {
        do {
            try await Self().main()
        } catch {
            fatalError("Error: \(error)")
        }
    }
    
}


public extension CommandInterface {
    
    func presentProgress(progress: Double) {
        let size = __getTerminalSize()
        let total = Int(size.ws_col - 2)
        let completed = Int(Double(total) * progress)
        
        let value = "[" + String(repeating: "=", count: completed) + String(repeating: " ", count: total - completed) + "]"
        print(value, terminator: "\r")
    }
    
}
