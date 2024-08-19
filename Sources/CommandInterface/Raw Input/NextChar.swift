//
//  NextChar.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


public enum NextChar: Equatable {
    case up
    case down
    case right
    case left
    case tab
    case newline
    case delete
    /// The full variadic unicode.
    case char(Character)
    case escape(Character)
    case badSymbol
    case empty
    
    /// Consume and returns next char.
    ///
    /// You need to ensure the Terminal is in raw mode by ``Terminal/setRawMode()``
    ///
    /// - Note: You need to `fflush` to push output.
    public static func consumeNext() -> NextChar? {
        let inputHandle = FileHandle.standardInput
        guard let next = try? inputHandle.read(upToCount: 1), let char = next.first else { return nil }
        
        switch char {
        case 27: // escape char
            if let next = try? inputHandle.read(upToCount: 2), let strings = String(data: next, encoding: .utf8) {
                let char = [Character](strings)
                if char.count == 2, char[0] == "[" {
                    switch char[1] {
                    case "A":
                        return .up
                    case "B":
                        return .down
                    case "C":
                        return .right
                    case "D":
                        return .left
                    default:
                        return .escape(char[1])
                    }
                } else {
                    return .badSymbol
                }
            } else {
                return .badSymbol
            }
            
        case 9:
            return .tab
            
        case 10:
            return .newline
            
        case 127:
            return .delete
            
        default:
            if let width = UTF8.width(startsWith: char), width != 1 {
                if var next = try? inputHandle.read(upToCount: width - 1) {
                    next.insert(char, at: 0)
                    var iterator = next.makeIterator()
                    
                    var utf = UTF8()
                    
                    while true {
                        switch utf.decode(&iterator) {
                        case .scalarValue(let v): return .char(Character(v))
                        case .emptyInput: return .empty
                        case .error: return .badSymbol
                        }
                    }
                } else {
                    return .badSymbol
                }
            }
            
            return .char(Character(UnicodeScalar(char)))
        }
    }
}
