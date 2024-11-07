//
//  Default Input.swift
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
    @Tag static var defaultValue: Tag
}

@Suite(.tags(.defaultValue, .input), .serialized)
@MainActor
struct DefaultValueInput {
    
    func test(
        input: String,
        match: String,
        return returnValue: String = "abc",
        terminator: String = "\n",
        expect: (String, String?) -> Void
    ) throws {
        let handle = try withStandardOutputCaptured {
            simulateUserInput(input + terminator)
            let string = try Terminal.read(.string.default("abc"), prompt: "")
            Terminal.print(">>>\(string)", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        let _match = match
            .replacingOccurrences(of: "^[", with: "\(Terminal.escape)")
        let match = "\(_match)\(terminator)\(Terminal.escape)[0J>>>\(returnValue)"
        expect(match, string)
    }
    
    @Test func emptyInput() async throws {
        try test(
            input: "",
            match: "^[[2mabc^[[0m^[[3D",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func matchingInput() async throws {
        try test(
            input: "a",
            match: "^[[2mabc^[[0m^[[3Da",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func unmatchingInput() async throws {
        try test(
            input: "f",
            match: "^[[2mabc^[[0m^[[3D^[[0Kf",
            return: "f",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func emptyInputTab() async throws {
        try test(
            input: "\t",
            match: "^[[2mabc^[[0m^[[3Dabc",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func matchingInputTab() async throws {
        try test(
            input: "a\t",
            match: "^[[2mabc^[[0m^[[3Dabc",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func unmatchingInputTab() async throws {
        try test(
            input: "f\t",
            match: "^[[2mabc^[[0m^[[3D^[[0Kf",
            return: "f",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func deleteBeforeCursor() throws {
        try test(
            input: "\u{7F}\t",
            match: "^[[2mabc^[[0m^[[3Dabc",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func moveRight() throws {
        try test(
            input: "\(Character.right)",
            match: "^[[2mabc^[[0m^[[3Dabc^[[2D",
            expect: { #expect($0 == $1) }
        )
    }
    
    @Test func fillThenDeleteBeforeCursor() throws {
        try test(
            input: "ab\(Character.left)\u{7F}\t",
            match: "^[[2mabc^[[0m^[[3Dab^[[1D^[[1C^[[1P^[[1D^[[1D^[[1P",
            return: "b",
            expect: { #expect($0 == $1) }
        )
    }
    
    init() {
        Terminal.setRawMode()
    }
    
}
