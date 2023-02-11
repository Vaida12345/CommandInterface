import XCTest
@testable import CommandInterface


final class CommandInterfaceTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        command().main()
    }
    
    struct command: CommandInterface {
        func main() {
            
        }
        
    }
}
