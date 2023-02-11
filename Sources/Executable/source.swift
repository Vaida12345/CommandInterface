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
        print("Line 1")
        print("Line 2")
        print("\u{001B}[2J", terminator: "")
        print("Line 3")
    }
    
}
