//
//  BasicTests.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import FinderItem
@testable
import CommandInterface
import Testing
import Essentials


extension Tag {
    @Tag static var basic: Tag
}

@Suite(.tags(.basic, .output), .serialized)
@MainActor
struct BasicTests {
    
    @Test func output() throws {
        let handle = try withStandardOutputCaptured {
            Terminal.print("abcd", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        #expect(string == "abcd")
    }
    
    init() {
        Terminal.setRawMode()
    }
    
}
