
import Foundation
import CommandInterface


var __raw = __setRawMode(); defer { __resetTerminal(originalTerm: &__raw) }

var storage = StandardInputStorage()

print("Enter: ", terminator: "")

storage.insertAtCursor("ABCD")
//storage.move(to: .left, length: 2)
let inserted = storage.insertAtCursor(formatted: "\("1234", modifier: .dim)")
storage.move(to: .left, length: inserted)

//dump(storage)

while let next = __consumeNext() {
    storage.handle(next)
}
