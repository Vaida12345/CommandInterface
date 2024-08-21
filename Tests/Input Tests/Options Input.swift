//
//  Options Input.swift
//  CommandInterface
//
//  Created by Vaida on 8/21/24.
//

import Foundation
import Stratum
@testable
import CommandInterface
import Testing


extension Tag {
    @Tag static var options: Tag
}

@Suite(.tags(.options, .input), .serialized)
@MainActor
struct OptionsInput {
    
    func test(
        input: String,
        match: String,
        return returnValue: String,
        terminator: String = "\n",
        expect: (String, String?) -> Void
    ) throws {
        let handle = try withStandardOutputCaptured {
            simulateUserInput(input + terminator)
            let string = Terminal.defaultInterface.read(.options(["option 10000", "option 20000", "option 30000"]), prompt: "")
            Terminal.defaultInterface.print(">>>\(string)", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        let _match = match
            .replacingOccurrences(of: "^[", with: "\(Terminal.escape)")
        let match = "\(_match)\(terminator)\(Terminal.escape)[0J>>>\(returnValue)"
        expect(match, string)
    }
    
    @Test(arguments: [("\t", false), (Character.up, true), (Character.down, false)], 1...5)
    func rotate(symbol: (Character, Bool), rotateCount: Int) async throws {
        var pool = ["option 10000", "option 20000", "option 30000"]
        if symbol.1 {
            pool.reverse()
        }
        
        let joint = (0..<rotateCount).map { pool[$0 % 3] }.joined(separator: "^[[12D^[[12P")
        
        try test(
            input: String(repeating: symbol.0, count: rotateCount),
            match: joint,
            return: pool[(rotateCount - 1) % 3],
            expect: { #expect($0 == $1) }
        )
    }
    
    
    init() {
        Terminal.setRawMode()
    }
    
    
}
