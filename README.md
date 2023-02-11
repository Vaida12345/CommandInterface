# CommandInterface

The interface for your command-line program.

## Usage

Please declare a `@main` struct that conforms to `CommandInterface`. In the structure, a `main()` method needs to be implemented, which marks as the entry point.

## Getting started

In your command-line tool, please include `CommandInterface` in your target dependency/

In your package, please use the following:

```swift
dependencies: [
    .package(url: )
]
```

## Note

Some of the functions only show correct output in Terminal, not Xcode.
