# ``CommandInterface``

An interface to your Command Line

@Metadata {
    @PageColor(gray)
    
    @SupportedLanguage(swift)
    
    @Available(macOS, introduced: 13.0)
}


## Overview

This package implemented many low-level terminal operations, and even a terminal I/O enumerator.

### Read user input

This package provides terminal interface for reading user inputs.

```swift
try read(.string.default("abcd").stopSequence(/\?/), prompt: "enter: ")
```

![Read Demo](read_demo)

### Styled Prints

You can print using various modifiers.

```swift
let hello = "Hello!"
print("\(hello, modifier: .italic.underline().foregroundColor(.blue))")
```

![Print Demo](print_demo)

### Working with Raw Terminal

The following code would reflect whatever the user input, except when the user presses the up key, in which case it would print *Move keyboard up!*, and not taking *any other* action to the up key.

```swift
@main
public struct Command: CommandInterface, AsyncParsableCommand {

    public mutating func run() async throws {
        Terminal.setRawMode(); defer { Terminal.reset() }

        var storage = StandardInputStorage()
            while let next = NextChar.consumeNext() {
                switch next {
                case .up:
                    print("Move keyboard up!")
                    break
                default:
                    storage.handle(next)
                }
            }
        }
    }
}
```

The first line is always required as the wrapper, which sets the terminal into raw mode.

```
Terminal.setRawMode()
```


## Topics

### Entrance

- ``CommandInterface``

### Read User Input

- ``CommandInterface/CommandInterface/read(_:prompt:condition:)``
- ``CommandInterface/CommandReadable``
- <doc:CommandReadableContent>

### Print Content

- ``CommandInterface/CommandInterface/print(_:terminator:)``
- ``CommandInterface/CommandPrintManager``

### Controls

- ``CommandInterface/Terminal``
- ``CommandInterface/Cursor``

### Interaction with Terminal

- ``CommandInterface/StandardInputStorage``
- ``CommandInterface/NextChar``
