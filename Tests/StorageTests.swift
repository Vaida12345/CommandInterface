//
//  StorageTests.swift
//  CommandInterface
//
//  Created by Vaida on 8/21/24.
//

import Stratum
import CommandInterface
import Testing


extension Tag {
    @Tag static var storage: Tag
}

@Suite(.tags(.storage), .serialized)
@MainActor
struct StorageTests {
    
    func test(
        match: String,
        return returnValue: String = "abc",
        block: (_ storage: inout StandardInputStorage) -> Void,
        expect: (String, String?, String, String) -> Void
    ) throws {
        var storage = StandardInputStorage()
        let handle = try withStandardOutputCaptured {
            block(&storage)
        }
        
        let string = try String(data: handle.readToEnd()!, encoding: .utf8)
        let _match = match
            .replacingOccurrences(of: "^[", with: "\(Terminal.escape)")
        expect(_match, string, returnValue, storage.get())
    }
    
    @Test func deleteOnce() throws {
        try test(
            match: "abcd^[[1D^[[1P",
            return: "abc") { storage in
                storage.write("abcd")
                storage.deleteBeforeCursor()
            } expect: {
                #expect($0 == $1)
                #expect($2 == $3)
            }
    }
    
    @Test func moveDeleteOnce() throws {
        try test(
            match: "abcd^[[1D^[[1D^[[1P",
            return: "abd") { storage in
                storage.write("abcd")
                storage.move(to: .left)
                storage.deleteBeforeCursor()
            } expect: {
                #expect($0 == $1)
                #expect($2 == $3)
            }
    }
    
    @Test func deleteOnceEmoji() throws {
        try test(
            match: "😊^[[2D^[[2P",
            return: "") { storage in
                storage.write("😊")
                storage.deleteBeforeCursor()
            } expect: {
                #expect($0 == $1)
                #expect($2 == $3)
            }
    }
    
    @Test func deleteTwice() throws {
        try test(
            match: "abcd^[[2D^[[2P",
            return: "ab") { storage in
                storage.write("abcd")
                storage.deleteBeforeCursor(count: 2)
            } expect: {
                #expect($0 == $1)
                #expect($2 == $3)
            }
    }
    
    @Test func deleteAll() throws {
        try test(
            match: "abcd^[[4D^[[4P",
            return: "") { storage in
                storage.write("abcd")
                #expect(storage.clearEntered() == "abcd")
            } expect: {
                #expect($0 == $1)
                #expect($2 == $3)
            }
    }
    
    
    init() {
        Terminal.setRawMode()
    }
    
}
