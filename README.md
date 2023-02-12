# CommandInterface

The interface for your command-line program.

## Usage

Please declare a `@main` struct that conforms to `CommandInterface`. In the structure, a `main()` method needs to be implemented, which marks as the entry point.

```swift
import CommandInterface

@main
private struct Command: CommandInterface {
    
    func main() throws {
        let value = self.read(.double, prompt: "value")
            .get()
        
        print("Read value: \(value)") {
            $0.foregroundColor(.blue)
        }
        
    }
}
```

## Getting started

In your command-line tool, please include `CommandInterface` in your target dependency/

In your package, please use the following:

```swift
dependencies: [
    .package(url: "https://github.com/Vaida12345/CommandInterface")
]
```

## Note

Some of the functions only show correct output in Terminal, not Xcode.
