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
        let match = "String here: hello!\n>>>hello!"
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
        let match = "read: ^[[2mabcd^[[0m^[[1D^[[1D^[[1D^[[1D^[[1C^[[1C^[[1C^[[1C^[[1D^[[P^[[1D^[[P^[[1D^[[P^[[1D^[[P?".replacingOccurrences(of: "^[", with: "\(Terminal.escape)") + ">>>?"
        #expect(string == match)
    }
    
    @Suite(.tags(.defaultValue), .serialized)
    @MainActor
    struct DefaultValue {
        
        @Test func emptyInput() async throws {
            let handle = try withStandardOutputCaptured {
                simulateUserInput("\n")
                let string = Terminal.defaultInterface.read(.string.default("abcd"), prompt: "read: ")
                Terminal.defaultInterface.print(">>>\(string)", terminator: "")
            }
            
            let string = try String(data: handle.readToEnd()!, encoding: .utf8)
            let match = "read: \(Terminal.escape)[2mabcd\(Terminal.escape)[0m\(Terminal.escape)[1D\(Terminal.escape)[1D\(Terminal.escape)[1D\(Terminal.escape)[1D\n>>>abcd"
            #expect(string == match)
        }
        
        @Test func matchingInput() async throws {
            let handle = try withStandardOutputCaptured {
                simulateUserInput("a\n")
                let string = Terminal.defaultInterface.read(.string.default("abcd"), prompt: "read: ")
                Terminal.defaultInterface.print(">>>\(string)", terminator: "")
            }
            
            let string = try String(data: handle.readToEnd()!, encoding: .utf8)
            let match = "read: \(Terminal.escape)[2mabcd\(Terminal.escape)[0m\(Terminal.escape)[1D\(Terminal.escape)[1D\(Terminal.escape)[1D\(Terminal.escape)[1Da\n>>>abcd"
            #expect(string == match)
        }
        
        @Test func unmatchingInput() async throws {
            let handle = try withStandardOutputCaptured {
                simulateUserInput("f\n")
                let string = Terminal.defaultInterface.read(.string.default("abcd"), prompt: "read: ")
                Terminal.defaultInterface.print(">>>\(string)", terminator: "")
            }
            
            let string = try String(data: handle.readToEnd()!, encoding: .utf8)
            let match = "read: ^[[2mabcd^[[0m^[[1D^[[1D^[[1D^[[1D^[[1C^[[1C^[[1C^[[1C^[[1D^[[P^[[1D^[[P^[[1D^[[P^[[1D^[[Pf".replacingOccurrences(of: "^[", with: "\(Terminal.escape)") + "\n>>>f"
            #expect(string == match)
        }
        
        @Test func emptyInputTab() async throws {
            let handle = try withStandardOutputCaptured {
                simulateUserInput("\t\n")
                let string = Terminal.defaultInterface.read(.string.default("abcd"), prompt: "read: ")
                Terminal.defaultInterface.print(">>>\(string)", terminator: "")
            }
            
            let string = try String(data: handle.readToEnd()!, encoding: .utf8)
            let match = "read: ^[[2mabcd^[[0m^[[1D^[[1D^[[1D^[[1Dabcd".replacingOccurrences(of: "^[", with: "\(Terminal.escape)") + "\n>>>abcd"
            #expect(string == match)
        }
        
        @Test func matchingInputTab() async throws {
            let handle = try withStandardOutputCaptured {
                simulateUserInput("a\t\n")
                let string = Terminal.defaultInterface.read(.string.default("abcd"), prompt: "read: ")
                Terminal.defaultInterface.print(">>>\(string)", terminator: "")
            }
            
            let string = try String(data: handle.readToEnd()!, encoding: .utf8)
            let match = "read: ^[[2mabcd^[[0m^[[1D^[[1D^[[1D^[[1Dabcd".replacingOccurrences(of: "^[", with: "\(Terminal.escape)") + "\n>>>abcd"
            #expect(string == match)
        }
        
        @Test func unmatchingInputTab() async throws {
            let handle = try withStandardOutputCaptured {
                simulateUserInput("f\t\n")
                let string = Terminal.defaultInterface.read(.string.default("abcd"), prompt: "read: ")
                Terminal.defaultInterface.print(">>>\(string)", terminator: "")
            }
            
            let string = try String(data: handle.readToEnd()!, encoding: .utf8)
            let match = "read: ^[[2mabcd^[[0m^[[1D^[[1D^[[1D^[[1D^[[1C^[[1C^[[1C^[[1C^[[1D^[[P^[[1D^[[P^[[1D^[[P^[[1D^[[Pf".replacingOccurrences(of: "^[", with: "\(Terminal.escape)") + "\n>>>f"
            #expect(string == match)
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
