
import Foundation
import CommandInterface
import RegexBuilder



var __raw = __setRawMode(); defer { __resetTerminal(originalTerm: &__raw) }

enum Option: String, CaseIterable {
    case aaaaaaaaaa1
    case aaaaaaaaaa31415926535
}

struct Interface: CommandInterface {
    
}
let interface = Interface()

//let input = interface.read(.options(from: Option.self), prompt: "Enter: ")
//print(input)

print()
print()
print()

print("0000_0000", terminator: "")
Cursor.move(toRight: 2)
print(Cursor.currentPosition())


print("0000_", terminator: "")
print("\(Terminal.escape)[6n")
