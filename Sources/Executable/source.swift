//
//  source.swift
//  The Command Interface Module
//
//  Created by Vaida on 2/12/23.
//  Copyright © 2019 - 2023 Vaida. All rights reserved.
//


import CommandInterface

@main
private struct Command: CommandInterface {
    
    func run() throws {
        
        let value = self.read(.double, prompt: "value")
            .default(value: 3.14)
            .condition { $0 < 0 }
            .get()

        print("Read value: \(value)") {
            $0.foregroundColor(.blue)
        }
        
    }
}
