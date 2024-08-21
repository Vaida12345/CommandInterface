//
//  StandardInputStorage.swift
//  CommandInterface
//
//  Created by Vaida on 8/19/24.
//

import Foundation


/// Any mutation on the storage is reflected on the Terminal.
public struct StandardInputStorage {
    
    /// The unformatted buffer.
    private var buffer: [Character]
    
    /// The cursor records the position using number of `Character`s, not count of utf8.
    ///
    /// A cursor position of `zero` indicates before the position before the first character.
    public private(set) var cursor: Int
    
    
    @discardableResult
    public mutating func move(to direction: Direction) -> Int? {
        switch direction {
        case .left:
            if cursor > 0 {
                let len = min(buffer[cursor - 1].utf8.count, 2)
                Cursor.move(toLeft: len)
                cursor -= 1
                return len
            }
        case .right:
            if cursor < buffer.count {
                let len = min(buffer[cursor].utf8.count, 2)
                Cursor.move(toRight: len)
                cursor += 1
                return len
            }
        }
        
        return nil
    }
    
    
    public mutating func move(to direction: Direction, length: Int) {
        if length == 0 {
            return
        } else if length < 0 {
            self.move(to: direction.opposite(), length: abs(length))
        } else {
            switch direction {
            case .left:
                let length = min(length, self.cursor)
                Terminal.cursor.move(toLeft: length)
                self.cursor -= length
            case .right:
                let length = min(length, self.buffer.count - self.cursor)
                Terminal.cursor.move(toRight: length)
                self.cursor += length
            }
        }
    }
    
    /// The number of elements in the buffer.
    public var count: Int {
        self.buffer.count
    }
    
    /// Gets the buffer.
    public func get() -> String {
        String(self.buffer)
    }
    
    /// Gets the content before cursor.
    public func getBeforeCursor() -> String {
        return String(self.buffer[0..<cursor])
    }
    
    /// Gets the char at cursor.
    public func getCursorChar() -> Character? {
        guard self.cursor < self.buffer.count else { return nil }
        return self.buffer[self.cursor]
    }
    
    /// Delete the value immediately before the cursor, which is the normal use of delete.
    public mutating func deleteBeforeCursor(count: Int = 1) {
        guard count != 0 else { return }
        
        var num = 0
        var shift = 0
        for _ in 1...count {
            if cursor > 0 {
                let dis = min(buffer[cursor - 1].utf8.count, 2)
                num += dis
                cursor -= 1
                shift += 1
            }
        }
        
        print("\(Terminal.escape)[\(num)D", terminator: "") // move to left
        print("\(Terminal.escape)[\(num)P", terminator: "") // clear
        fflush(stdout);
        
        buffer.replaceSubrange(self.cursor ..< self.cursor + shift, with: "")
    }
    
    /// Delete the value immediately after the cursor.
    public mutating func deleteAfterCursor(count: Int = 1) {
        guard count != 0 else { return }
        
        var num = 0
        var shift = 0
        for _ in 1...count {
            if cursor < self.buffer.count {
                let dis = min(buffer[cursor - 1 + shift].utf8.count, 2)
                num += dis
                shift += 1
            }
        }
        
        print("\(Terminal.escape)[\(num)P", terminator: "") // clear
        fflush(stdout);
        
        buffer.replaceSubrange(self.cursor ..< self.cursor + shift, with: "")
    }
    
    public mutating func insertAtCursor(_ value: Character) {
        if cursor == buffer.count {
            print(value, terminator: "")
        } else {
            print("\(Terminal.escape)[@\(value)", terminator: "")
        }
        
        fflush(stdout);
        
        buffer.insert(value, at: cursor)
        cursor += 1
    }
    
    /// Write the `value`, replacing any existing characters.
    public mutating func write(_ value: Character) {
        print(value, terminator: "")
        fflush(stdout);
        
        if cursor < buffer.count {
            buffer.remove(at: cursor)
        }
        buffer.insert(value, at: cursor)
        cursor += 1
    }
    
    /// Write the `value`, replacing any existing characters.
    @inlinable
    public mutating func write(_ value: String) {
        for char in value {
            self.write(char)
        }
    }
    
    
    public mutating func write(formatted item: CommandPrintManager.Interpolation) -> Int {
        let item = item.getInterpolation()
        print(item.description, terminator: "")
        fflush(stdout)
        
        let raw = item.getRaw()
        for _ in cursor..<min(buffer.count, raw.count + cursor) {
            buffer.remove(at: cursor)
        }
        buffer.insert(contentsOf: raw, at: cursor)
        cursor += raw.count
        return raw.count
    }
    
    @discardableResult
    public mutating func insertAtCursor(_ value: String) -> Int {
        if cursor == buffer.count {
            print(value, terminator: "")
            fflush(stdout);
            
            buffer.append(contentsOf: value)
            cursor += value.count
        } else {
            for char in value {
                self.insertAtCursor(char)
            }
        }
        
        return buffer.count
    }
    
    public mutating func eraseFromCursorToEndOfLine() {
        Terminal.eraseFromCursorToEndOfLine()
        
        let count = self.buffer.count - self.cursor
        self.buffer.removeLast(count)
    }
    
    /// Seek to end, and returns the shift
    @discardableResult
    public mutating func seekToEnd() -> Int {
        let shift = self.buffer.count - self.cursor
        move(to: .right, length: shift)
        return shift
    }
    
    
    @discardableResult
    public mutating func insertAtCursor(formatted item: CommandPrintManager.Interpolation) -> Int {
        let item = item.getInterpolation()
        let raw = item.getRaw()
        
        guard !raw.isEmpty else { return 0 }
        if cursor == buffer.count {
            print(item.description, terminator: "")
            fflush(stdout);
            
            buffer.append(contentsOf: raw)
            cursor += raw.count
            return raw.count
        } else {
            let place = raw.count
            // allocate space
            self.insertAtCursor(String(repeating: " ", count: place))
            // move back
            self.move(to: .left, length: place)
            // write
            return self.write(formatted: item)
        }
    }
    
    /// Clear entered values as recorded by `self`.
    @discardableResult
    public mutating func clearEntered() -> String {
        defer {
            // rotate to end
            self.move(to: .right, length: self.buffer.count - cursor)
            self.deleteBeforeCursor(count: self.buffer.count)
        }
        return String(buffer)
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
            insertAtCursor(" ")
        case .newline:
            insertAtCursor("\n")
        case .delete:
            deleteBeforeCursor()
        case .char(let character):
            insertAtCursor(character)
        case .escape(let character):
            insertAtCursor("\(Terminal.escape)[\(character)")
        case .badSymbol:
            break
        case .empty:
            break
        }
    }
    
    
    public enum Direction {
        case left, right
        
        func opposite() -> Direction {
            switch self {
            case .left:
                    .right
            case .right:
                    .left
            }
        }
    }
    
    public init(buffer: [Character] = [], cursor: Int = 0) {
        self.buffer = buffer
        self.cursor = cursor
    }
    
}
