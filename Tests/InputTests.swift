//
//  InputTests.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation
import Stratum
import CommandInterface
import Testing


extension Tag {
    @Tag static var input: Tag
    @Tag static var defaultValue: Tag
}

@Suite(.tags(.input), .serialized)
@MainActor
struct InputTests {
    
    @Test func stringInput() throws {
        let handle = try withStandardOutputCaptured {
            simulateUserInput("hello!\n")
            let string = Terminal.defaultInterface.read(.string, prompt: "String here: ")
            Terminal.defaultInterface.print(">>>\(string)", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        let match = "String here: hello!\n\(Terminal.escape)[0J>>>hello!"
        #expect(string == match)
    }
    
    @Test func fileInput() throws {
        _ = try withStandardOutputCaptured {
            simulateUserInput("/Users/vaida/DataBase/Static/Do\\ not\\ modify.txt \n")
            let file = Terminal.defaultInterface.read(.finderItem, prompt: "file here: ")
            
            let match = FinderItem(at: "/Users/vaida/DataBase/Static/Do not modify.txt")
            #expect(file == match)
        }
    }
    
    @Test func stoppedInput() async throws {
        let handle = try withStandardOutputCaptured {
            simulateUserInput("?")
            let string = Terminal.defaultInterface.read(.string.default("abcd").stopSequence(/\?/), prompt: "read: ")
            Terminal.defaultInterface.print(">>>\(string)", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        let match = "read: ^[[2mabcd^[[0m^[[1D^[[1D^[[1D^[[1D^[[0K?\(Terminal.escape)[0J".replacingOccurrences(of: "^[", with: "\(Terminal.escape)") + ">>>?"
        #expect(string == match)
    }
    
    @Test func transformedInput() async throws {
        let handle = try withStandardOutputCaptured {
            simulateUserInput("\n")
            let string = Terminal.defaultInterface.read(.bool.default(true), prompt: "")
            Terminal.defaultInterface.print(">>>\(string)", terminator: "")
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        let match = "^[[2myes^[[0m^[[1D^[[1D^[[1D".replacingOccurrences(of: "^[", with: "\(Terminal.escape)") + "\n\(Terminal.escape)[0J>>>true"
        #expect(string == match)
    }
    
    @Suite(.tags(.defaultValue), .serialized)
    @MainActor
    struct DefaultValue {
        
        func test(
            input: String,
            match: String,
            return returnValue: String = "abc",
            terminator: String = "\n",
            expect: (String, String?) -> Void
        ) throws {
            let handle = try withStandardOutputCaptured {
                simulateUserInput(input + terminator)
                let string = Terminal.defaultInterface.read(.string.default("abc"), prompt: "")
                Terminal.defaultInterface.print(">>>\(string)", terminator: "")
            }
            
            let string = try String(data: handle.readToEnd()!, encoding: .utf8)
            let _match = match
                .replacingOccurrences(of: "^[", with: "\(Terminal.escape)")
                .replacingOccurrences(of: "\r", with: "\\r")
            let match = "\(_match)\(terminator)\(Terminal.escape)[0J>>>\(returnValue)"
            expect(match, string)
        }
        
        @Test func emptyInput() async throws {
            try test(
                input: "",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1D",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func matchingInput() async throws {
            try test(
                input: "a",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1Da",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func unmatchingInput() async throws {
            try test(
                input: "f",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1D^[[0Kf",
                return: "f",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func emptyInputTab() async throws {
            try test(
                input: "\t",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1Dabc",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func matchingInputTab() async throws {
            try test(
                input: "a\t",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1Dabc",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func unmatchingInputTab() async throws {
            try test(
                input: "f\t",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1D^[[0Kf",
                return: "f",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func deleteBeforeCursor() throws {
            try test(
                input: "\u{7F}\t",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1Dabc",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func moveRight() throws {
            try test(
                input: "\(Character.right)",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1Dabc^[[1D^[[1D",
                expect: { #expect($0 == $1) }
            )
        }
        
        @Test func fillThenDeleteBeforeCursor() throws {
            try test(
                input: "ab\(Character.left)\u{7F}\t",
                match: "^[[2mabc^[[0m^[[1D^[[1D^[[1Dab^[[1D^[[1C^[[1C^[[1D^[[P^[[1D^[[1D^[[P",
                return: "b",
                expect: { #expect($0 == $1) }
            )
        }
        
        init() {
            Terminal.setRawMode()
        }
        
    }
    
    
    init() {
        Terminal.setRawMode()
    }
    
}


func simulateUserInput(_ input: String) {
    let pipe = Pipe()
    let inputData = input.data(using: .utf8)!
    pipe.fileHandleForWriting.write(inputData)
    pipe.fileHandleForWriting.closeFile()
    
    // Redirect stdin to use the pipe's read end
    freopen("/dev/null", "r", stdin) // Close the current stdin
    dup2(pipe.fileHandleForReading.fileDescriptor, STDIN_FILENO)
}

extension Character {
    static var up: Character {
        let sequence: [UInt8] = [239, 156, 128]
        return String(data: Data(sequence), encoding: .utf8)!.first!
    }
    
    static var down: Character {
        let sequence: [UInt8] = [239, 156, 129]
        return String(data: Data(sequence), encoding: .utf8)!.first!
    }
    
    static var left: Character {
        let sequence: [UInt8] = [239, 156, 130]
        return String(data: Data(sequence), encoding: .utf8)!.first!
    }
    
    static var right: Character {
        let sequence: [UInt8] = [239, 156, 131]
        return String(data: Data(sequence), encoding: .utf8)!.first!
    }
}


//if sequence.starts(with: [239, 156]), sequence.count == 3 { // Xcode input
//    switch sequence[2] {
//    case 128:
//        return .up
