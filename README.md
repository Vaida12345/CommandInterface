# CommandInterface

An interface to your Command Line

## Overview

This package implemented many low-level terminal operations, and even a terminal I/O enumerator.

### Read user input

This package provides terminal interface for reading user inputs.

```swift
try read(.string.default("abcd").stopSequence(/\?/), prompt: "enter: ")
```

<picture>
  <source srcset="https://vaida12345.github.io/CommandInterface/images/commandinterface.CommandInterface/read_demo~dark@2x.png" media="(prefers-color-scheme: dark)">
  <img src="https://vaida12345.github.io/CommandInterface/images/commandinterface.CommandInterface/read_demo@2x.png" alt="Your Image">
</picture>

### Styled Prints

You can print using various modifiers.

```swift
let hello = "Hello!"
print("\(hello, modifier: .italic.underline().foregroundColor(.blue))")
```

<picture>
  <source srcset="https://vaida12345.github.io/CommandInterface/images/commandinterface.CommandInterface/print_demo~dark@2x.png" media="(prefers-color-scheme: dark)">
  <img src="https://vaida12345.github.io/CommandInterface/images/commandinterface.CommandInterface/print_demo@2x.png" alt="Your Image">
</picture>

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

## Getting Started

`FinderItem` uses [Swift Package Manager](https://www.swift.org/documentation/package-manager/) as its build tool. If you want to import in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/Vaida12345/CommandInterface", from: "1.0.0")
]
```
and then adding the appropriate module to your target dependencies.

### Using Xcode Package support

You can add this framework as a dependency to your Xcode project by clicking File -> Swift Packages -> Add Package Dependency. The package is located at:
```
https://github.com/Vaida12345/CommandInterface
```

## Documentation

This package uses [DocC](https://www.swift.org/documentation/docc/) for documentation. [View on Github Pages](https://vaida12345.github.io/CommandInterface/documentation/commandinterface/)
