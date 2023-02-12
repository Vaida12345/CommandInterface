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
    
    func main() throws {
        
        let value = self.read(.double, prompt: "value")
            .get()
        
        print("Read value: \(value)") {
            $0.foregroundColor(.blue)
        }
        
    }
}
