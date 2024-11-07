//
//  InputReader.swift
//  CommandInterface
//
//  Created by Vaida on 11/8/24.
//

import Foundation
import Stratum


public class CommandInputReader {
    
    let configuration: _Configuration
    
    var storage: StandardInputStorage
    
    
    init(configuration: _Configuration, storage: StandardInputStorage = StandardInputStorage()) {
        self.configuration = configuration
        self.storage = storage
    }
    
    
    /// Handles the next char provided by stdin.
    ///
    /// - Returns: A valid string when wishes to early return.
    public func handle(_ next: NextChar) throws -> String? {
        switch next {
        case .newline:
            Swift.print("\n", terminator: "")
            fflush(stdout)
            return storage.get()
            
        case .tab:
            // do nothing
            break
            
        default:
            storage.handle(next)
        }
        
        return nil
    }
    
    /// Called in ``read()`` after ``handle(_:)``.
    ///
    /// - Returns: A valid string when wishes to early return.
    public func didHandleNextChar() -> String? {
        let string = storage.get()
        if configuration.stopSequence.contains(where: { (try? $0.wholeMatch(in: string)) != nil }) {
            return string
        }
        
        return nil
    }
    
    /// Calls ``handle(_:)``, and return the results
    public func read() throws -> String? {
        while let next = try NextChar.consumeNext() {
            if let string = try handle(next) {
                return string
            }
            
            if let string = didHandleNextChar() {
                return string
            }
        }
        
        return nil
    }
    
}
