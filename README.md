# CommandInterface

The interface for your command-line program.

## Usage

Please declare a `@main` struct that conforms to `CommandInterface`. In the structure, a `main()` method needs to be implemented, which marks as the entry point.

```swift
import CommandInterface

@main
private struct Command: CommandInterface {
    
    func main() throws {
        let value = self.read(.double, prompt: "Enter a value")
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

For escape codes, see [here by fnky](https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797).

> Please note that not all the terminals supports all the escape codes. The Mac Terminal is no expection. 
