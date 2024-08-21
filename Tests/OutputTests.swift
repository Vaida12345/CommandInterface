//
//  OutputTests.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Stratum
@testable
import CommandInterface
import Testing


extension Tag {
    @Tag static var output: Tag
}

@Suite(.tags(.output), .serialized)
@MainActor
struct OutputTests {
    
    @Test func withColorVariations() throws {
        let handle = try withStandardOutputCaptured {
            Terminal.defaultInterface.print("\("blue", modifier: .foregroundColor(.blue))", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        #expect(string == "\(Terminal.escape)[34mblue\(Terminal.escape)[0m")
    }
    
    @Test func markdownEnabled() throws {
        let handle = try withStandardOutputCaptured {
            Terminal.defaultInterface.print("**Hello** *Swift*", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        let match = "\(Terminal.escape)[1mHello\(Terminal.escape)[0m \(Terminal.escape)[3mSwift\(Terminal.escape)[0m"
        #expect(string == match)
    }
    
    init() {
        Terminal.setRawMode()
    }
    
}
