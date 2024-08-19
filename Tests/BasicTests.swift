//
//  BasicTests.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Stratum
import CommandInterface
import Testing


extension Tag {
    @Tag static var basic: Tag
}

@Suite(.tags(.basic, .output), .serialized)
@MainActor
struct BasicTests {
    
    @Test func output() throws {
        let handle = try withStandardOutputCaptured {
            Terminal.defaultInterface.print("abcd", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        #expect(string == "abcd")
    }
    
    init() {
        Terminal.setRawMode()
    }
    
}
