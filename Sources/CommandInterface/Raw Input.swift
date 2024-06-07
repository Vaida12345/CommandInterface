//
//  Raw Input.swift
//
//
//  Created by Vaida on 6/7/24.
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
}


/// Consume and returns next char.
///
/// To use this, you must define the following in the function in which this is called.
///
/// - Note: You need to `fflush` to push output.
///
/// ```swift
/// var __raw = __setRawMode()
/// defer {
///     __resetTerminal(originalTerm: &__raw)
/// }
/// ```
@inlinable
public func __consumeNext() -> NextChar? {
    
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


// Function to set the terminal to raw mode
@inlinable
public func __setRawMode() -> termios {
    fflush(stdout)
    
    var originalTerm = termios()
    var rawTerm = termios()
    
    // Get the current terminal settings
    tcgetattr(STDIN_FILENO, &originalTerm)
    rawTerm = originalTerm
    
    // Set the terminal to raw mode
    rawTerm.c_lflag &= ~(UInt(ICANON | ECHO))
    rawTerm.c_cc.0 = 1 // VMIN
    rawTerm.c_cc.1 = 0 // VTIME
    
    tcsetattr(STDIN_FILENO, TCSANOW, &rawTerm)
    
    return originalTerm
}

// Function to reset the terminal to its original settings
@inlinable
public func __resetTerminal(originalTerm: inout termios) {
    tcsetattr(STDIN_FILENO, TCSANOW, &originalTerm)
}


/// Any mutation on the storage is reflected on the Terminal.
public struct StandardInputStorage {
    
    public var buffer: [Character]
    
    /// The cursor records the position using number of `Character`s, not count of utf8.
    public var cursor: Int
    
    
    @inlinable
    @discardableResult
    public mutating func move(to direction: Direction) -> Int? {
        switch direction {
        case .left:
            if cursor > 0 {
                let len = min(buffer[cursor - 1].utf8.count, 2)
                Cursor.move(toLeft: len)
                fflush(stdout);
                cursor -= 1
                return len
            }
        case .right:
            if cursor < buffer.count {
                let len = min(buffer[cursor].utf8.count, 2)
                Cursor.move(toRight: len)
                fflush(stdout);
                cursor += 1
                return len
            }
        }
        
        return nil
    }
    
    /// Delete the value right before the cursor, which is the normal use of delete.
    @inlinable
    public mutating func deleteBeforeCursor() {
        if cursor > 0 && cursor <= buffer.count, let dis = move(to: .left) {
            for _ in 1...dis {
                print("\(Terminal.escape)[P", terminator: "")
            }
            fflush(stdout);
            
            buffer.remove(at: cursor)
        }
    }
    
    @inlinable
    public mutating func insertAtCursor(_ value: Character) {
        print("\(Terminal.escape)[@\(value)", terminator: "")
        fflush(stdout);
        
        buffer.insert(value, at: cursor)
        cursor += 1
    }
    
    @inlinable
    public mutating func insertAtCursor(_ value: String) {
        for char in value {
            self.insertAtCursor(char)
        }
    }
    
    /// Clear entered values as recorded by `self`.
    @inlinable
    public mutating func clearEntered() {
        // rotate to start
        while cursor > 0 {
            self.move(to: .left)
        }
        Terminal.eraseFromCursorToEndOfLine()
        buffer.removeAll()
    }
    
    @inlinable
    public mutating func handle(_ next: NextChar) {
        switch next {
        case .up:
            break
        case .down:
            break
        case .right:
            move(to: .right)
        case .left:
            move(to: .left)
        case .tab:
            insertAtCursor("\t")
        case .newline:
            insertAtCursor("\n")
        case .delete:
            deleteBeforeCursor()
        case .char(let character):
            insertAtCursor(character)
        case .escape(let character):
            insertAtCursor(Terminal.escape)
        case .badSymbol:
            break
        case .empty:
            break
        }
    }
    
    
    public enum Direction {
        case left, right
    }
    
    @inlinable
    public init(buffer: [Character] = [], cursor: Int = 0) {
        self.buffer = buffer
        self.cursor = cursor
    }
    
}
