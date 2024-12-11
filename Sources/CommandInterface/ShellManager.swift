//
//  ShellManager.swift
//  The Stratum Module
//
//  Created by Vaida on 4/13/22.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#if os(macOS)
import Foundation
import FinderItem


/// A convenient interface to run shell.
///
/// - Important: One `ShellManager` can only deal with one task at a time.
///
/// **Initialization**
///
/// There are several ways to create a manager.
///
/// ```swift
/// // You can run the static method directly.
/// let shellManager = ShellManager.run(executable: "folder/executable", arguments: "ls")
///
/// // If you want you use the default shell (`/bin/zsh`), you can run this by
/// shellManager.run(arguments: "ls")
/// ```
///
/// **Getting results**
///
/// The ways of waiting for result.
///
/// ```swift
/// // You can obtain the result by
/// await shellManager.output()!
///
/// // Or, if you are not interested in the output
/// await shellManager.wait()
/// ```
///
/// ## Topics
///
/// ### Initialization
///
/// - ``run(executable:arguments:workingDirectory:)-swift.type.method``
/// - ``runInTerminal(lines:)``
///
///
/// ### Inspect outputs
///
/// - ``bytes()``
/// - ``lines()``
/// - ``output()``
///
///
/// ### Dealing with `stdin`
///
/// - ``write(_:)-1dmmo``
/// - ``write(_:)-1jjbc``
///
///
/// ### Control the execution
///
/// - ``terminate()``
/// - ``wait()``
/// - ``pause()``
/// - ``resume()``
/// - ``isRunning``
///
///
/// ### Additional setups
///
/// - ``init()``
/// - ``onTermination(handler:)``
/// - ``environment``
/// - ``run(executable:arguments:workingDirectory:)-swift.method``
///
/// ### Groups
///
/// - ``ShellManagers``
@dynamicMemberLookup
public final class ShellManager: Equatable, Hashable, Identifiable, @unchecked Sendable {
    
    /// The object that represents a subprocess of the current process.
    private var task: Process
    
    /// The one-way communications channel between related processes.
    private let standardInput: Pipe
    private let standardOutput: Pipe
    private let standardError: Pipe
    
    /// Returns a boolean value indicating whether the task is running.
    public var isRunning: Bool {
        task.isRunning
    }
    
    /// The environment for the receiver.
    ///
    /// If this method isn’t used, the environment is inherited from the process that created the receiver. This method raises an `NSInvalidArgumentException` if the system has launched the receiver.
    public var environment: [String : String]? {
        get {
            self.task.environment
        }
        set {
            self.task.environment = newValue
        }
    }
    
    /// Initialize a shell Manager.
    public init() {
        self.task = Process()
        self.standardInput = Pipe()
        self.standardOutput = Pipe()
        self.standardError = Pipe()
        
        task.standardInput = standardInput
        task.standardOutput = standardOutput
        task.standardError = standardError
    }
    
    deinit {
        task.terminationHandler = nil
    }
    
    /// Runs a task with a specified executable and arguments.
    ///
    /// - Parameters:
    ///   - executable: The optional executable file
    ///   - arguments: The arguments
    ///   - workingDirectory: Specify the optional working directory
    public func run(executable: FinderItem? = nil, arguments: String, workingDirectory: FinderItem? = nil) throws {
        self.task.currentDirectoryURL = workingDirectory?.url
        
        if let item = executable {
            self.task.executableURL = item.url
            self.task.arguments = [arguments]
            try self.task.run()
        } else {
            self.task.launchPath = "/bin/zsh"
            self.task.arguments = ["-c", arguments]
            try self.task.run()
        }
    }
    
    /// Reads results from the `Process`.
    public func output() -> String? {
        guard let data = try? self.standardOutput.fileHandleForReading.readToEnd() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// Reads `stderr` from the `Process`.
    public func error() -> String? {
        guard let data = try? self.standardError.fileHandleForReading.readToEnd() else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    /// The bytes that made up the `stdout`.
    ///
    /// - SeeAlso: ``lines()``.
    public func bytes() -> FileHandle.AsyncBytes {
        self.standardOutput.fileHandleForReading.bytes
    }
    
    /// The lines of `stdout`.
    ///
    /// > Example: 
    /// > To access the individual asynchronous lines,
    /// >
    /// > ```swift
    /// > for try await line in manager.lines() {
    /// >     // do something with `line`
    /// > }
    /// > ```
    public func lines() -> AsyncLineSequence<FileHandle.AsyncBytes> {
        self.standardOutput.fileHandleForReading.bytes.lines
    }
    
    /// Writes a string to stdin.
    ///
    /// - throws: ``WritingError``
    ///
    /// ## Topics
    /// ### Potential Error
    /// - ``WritingError``
    public func write(_ value: String) throws {
        guard let data = value.data(using: .utf8) else { throw WritingError.cannotFormDataFromString }
        try self.write(data)
    }
    
    public enum WritingError: GenericError {
        case cannotFormDataFromString
        
        public var title: String {
            "cannot write a string to `stdin`"
        }
        
        public var message: String {
            "Cannot form data from given string"
        }
    }
    
    /// Writes a data to stdin.
    public func write(_ value: some DataProtocol) throws {
        try self.standardInput.fileHandleForWriting.write(contentsOf: value)
    }
    
    /// Wait until exit.
    ///
    /// Blocks the process until the receiver is finished.
    ///
    /// = Returns: The termination status, `0` for success.
    @discardableResult
    public func wait() -> Int32 {
        task.waitUntilExit()
        return task.terminationStatus
    }
    
    /// Suspends execution of the receiver task.
    ///
    /// Multiple ``pause()`` messages can be sent, but they must be balanced with an equal number of ``resume()`` messages before the task resumes execution.
    public func pause() {
        task.suspend()
    }
    
    /// Resumes execution of a suspended task.
    ///
    /// Multiple ``pause()`` messages can be sent, but they must be balanced with an equal number of ``resume()`` messages before the task resumes execution.
    public func resume() {
        task.resume()
    }
    
    /// Sends a terminate signal to the receiver and all of its subtasks.
    public func terminate() {
        task.terminate()
    }
    
    /// A completion block the system invokes when the task completes.
    public func onTermination(handler: @Sendable @escaping (Process) -> Void) {
        task.terminationHandler = handler
    }
    
    /// Creates the hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.task)
    }
    
    
    /// Creates and runs a task with a specified executable and arguments.
    ///
    /// - Parameters:
    ///   - executable: The optional executable file
    ///   - arguments: The arguments
    ///   - workingDirectory: Specify the optional working directory
    public static func run(executable: FinderItem? = nil, arguments: String, workingDirectory: FinderItem? = nil) throws -> ShellManager {
        let manager = ShellManager()
        try manager.run(executable: executable, arguments: arguments, workingDirectory: workingDirectory)
        return manager
    }
    
    /// Runs a sequence of commands in terminal.
    ///
    /// You do not have any control to the command once dispatched. The function would return after the completion of execution.
    ///
    /// - throws: ``ScriptError``
    ///
    /// ## Topics
    /// ### Potential Error
    /// - ``ScriptError``
    public static func runInTerminal(lines: [String]) throws -> NSAppleEventDescriptor? {
        let script = """
            tell application "Terminal"
                activate
                do script "\(lines.joined(separator: "; "))"
            end tell
            """
        
        let appleScript = NSAppleScript(source: script)
        
        var error: NSDictionary?
        let result = appleScript?.executeAndReturnError(&error)
        
        if let error {
            throw ScriptError(title: error["NSAppleScriptErrorBriefMessage"] as? String ?? "some Apple Script Error", message: error["NSAppleScriptErrorMessage"] as? String ?? "\(error)")
        }
        
        return result
    }
    
    
    public struct ScriptError: GenericError {
        public let title: String
        public let message: String
    }
    
    
    /// Compares two managers.
    public static func == (lhs: ShellManager, rhs: ShellManager) -> Bool {
        lhs.task == rhs.task && lhs.id == rhs.id
    }
    
    /// The implementation of dynamic callable.
    public subscript<Subject>(dynamicMember keyPath: WritableKeyPath<Process, Subject>) -> Subject {
        get { self.task[keyPath: keyPath] }
        set { self.task[keyPath: keyPath] = newValue }
    }
    
    /// The implementation of dynamic callable.
    public subscript<Subject>(dynamicMember keyPath: KeyPath<Process, Subject>) -> Subject {
        self.task[keyPath: keyPath]
    }
    
}


/// A manager to manage a set of `ShellManager`s.
public final class ShellManagers: Hashable, Identifiable, @unchecked Sendable {
    
    /// The contained managers.
    private var contents: [ShellManager]
    
    /// Creates an empty manager.
    public init() {
        self.contents = []
    }
    
    /// Adds a new manager.
    public func addManager() -> ShellManager {
        let newManager = ShellManager()
        newManager.onTermination { [weak self, weak newManager] _ in
            if self != nil && self!.contents.count > 0 { // remove the element only if it has not been released.
                self!.contents.removeAll { $0 == newManager }
            }
        }
        self.contents.append(newManager)
        return newManager
    }
    
    /// Terminates and removes a manager.
    public func remove(manager: ShellManager) {
        manager.terminate()
        self.contents.removeAll { $0 == manager }
    }
    
    /// Resumes execution of all tasks.
    ///
    /// Multiple ``pause()`` messages can be sent, but they must be balanced with an equal number of ``resume()`` messages before the task resumes execution.
    public func resume() {
        for i in contents {
            i.resume()
        }
    }
    
    /// Sends a terminate signal to the all the receivers and all of their subtasks.
    public func terminate() {
        for i in contents {
            i.terminate()
        }
    }
    
    /// Sends a terminate signal to the all the running receivers and all of their subtasks.
    public func terminateIfPosible() {
        for i in contents {
            guard i.isRunning else { continue }
            i.terminate()
        }
    }
    
    /// Suspends execution of all the tasks.
    ///
    /// Multiple ``pause()`` messages can be sent, but they must be balanced with an equal number of ``resume()`` messages before the task resumes execution.
    public func pause() {
        for i in contents {
            i.pause()
        }
    }
    
    /// Creates a hash value.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(contents)
    }
    
    /// Compare two sets of managers.
    public static func == (lhs: ShellManagers, rhs: ShellManagers) -> Bool {
        lhs.contents == rhs.contents
    }
    
}
#endif
