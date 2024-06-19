
import Foundation
import CommandInterface
import RegexBuilder



var __raw = __setRawMode(); defer { __resetTerminal(originalTerm: &__raw) }

var storage = StandardInputStorage()
while let next = __consumeNext() {
    switch next {
    case .up:
        print("Move keyboard up!")
        break
    default:
        storage.handle(next)
    }
}
