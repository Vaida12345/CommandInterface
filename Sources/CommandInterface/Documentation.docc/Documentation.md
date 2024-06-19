# ``CommandInterface``

An interface to your Command Line

@Metadata {
    @PageColor(gray)
    
    @SupportedLanguage(swift)
    
    @Available(macOS, introduced: 13.0)
}


## Overview

This package implemented many low-level terminal operations, and even a terminal I/O enumerator.

The following code would reflect whatever the user input, except when the user presses the up key, in which case it would print *Move keyboard up!*, and not taking *any other* action to the up key.

```swift
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
```

The first line is always required as the wrapper, which sets the terminal into raw mode.

```
var __raw = __setRawMode(); defer { __resetTerminal(originalTerm: &__raw) }
```
