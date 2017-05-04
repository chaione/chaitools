//
//  ChaiCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/26/17.
//
//

import Foundation

public typealias ChaiCommandArguments = [String]

public protocol ChaiErrorProtocol: Error {
    var localizedDescription: String { get }
}

extension ChaiErrorProtocol {

    public static func generic(message: String) -> Error {
        return ChaiError(message: message)
    }
}

public struct ChaiError: ChaiErrorProtocol {
    public let localizedDescription: String
    init(message: String) {
        localizedDescription = message
    }
}

@available(OSX 10.12, *)

/// Protocol to handle any commands needed to be run in the terminal.
protocol ChaiCommand {

    /// Returns Array of String that will act as arguments for Process.
    ///
    /// - Returns: Array of Strings
    func arguments() -> ChaiCommandArguments

    /// executable name that will be executed. Example: `which`, `echo`, `ls`
    static var binary: String? { get }
}

@available(OSX 10.12, *)
extension ChaiCommand {

    /// Generates final array of commands with executable at the beginning.
    ///
    /// - Returns: `[ChaiCommandArguments]`
    private func binaryWithArguments() -> ChaiCommandArguments {
        guard let binary = type(of: self).binary else {
            return arguments()
        }
        return [binary] + arguments()
    }

    /// Executes command.
    ///
    /// - Parameter directory: URL of directory you will to run command inside of.
    /// - Returns: @discardableResult Process object that contains.
    /// - Throws: `CommandProtocolError` with `.generic` case.
    @discardableResult public func run(in directory: URL, output:((String) -> Void)? = nil) throws -> Process {

        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.currentDirectoryPath = directory.path
        process.arguments = binaryWithArguments()

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        defer {
            process.output = pipe.output()
        }

        if let outputBlock = output {
            handle(pipe: pipe, in: process, output: outputBlock)
        }

        process.execute()

        if process.terminationStatus != 0 {
            throw ChaiError.generic(message: pipe.output())
        }

        return process
    }

    /// Helper method that allows `ChaiCommand` object to output a stream of data from console using `NotificationCenter`.
    ///
    /// - Parameters:
    ///   - pipe: `Pipe`
    ///   - process: `Process`
    ///   - output: `((String) -> Void)` block that will run as new data is streamed in.
    internal func handle(pipe: Pipe, in process: Process, output outputBlock: @escaping ((String) -> Void)) {
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        var progressObserver: NSObjectProtocol!
        progressObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outHandle, queue: nil) { _ in
            let data = outHandle.availableData

            if data.count > 0 {
                if let str = String(data: data, encoding: String.Encoding.utf8) {
                    outputBlock(str.trimmingCharacters(in: .whitespacesAndNewlines))
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                // That means we've reached the end of the input.
                NotificationCenter.default.removeObserver(progressObserver)
            }
        }

        var terminationObserver: NSObjectProtocol!
        terminationObserver = NotificationCenter.default.addObserver(forName: Process.didTerminateNotification, object: process, queue: nil) { _ in
            // Process was terminated. Hence, progress should be 100%
            NotificationCenter.default.removeObserver(terminationObserver)
        }
    }

    /// Executes command.
    ///
    /// - Parameter directory: filePath of directory you will to run command inside of.
    /// - Returns: @discardableResult Process object that contains.
    /// - Throws: `CommandProtocolError` with `.generic` case.
    func run(in directoryPath: String) throws -> Process {
        return try run(in: URL(fileURLWithPath: directoryPath))
    }
}

// MARK: - External class extensions
public extension Process {

    @discardableResult func execute() -> Process {
        launch()
        waitUntilExit()
        return self
    }

    private static var optionsAssociationKey: UInt8 = 0
    var output: String {
        get {
            guard let outputStr = objc_getAssociatedObject(self, &Process.optionsAssociationKey) as? String
            else { return "" }
            return outputStr
        }
        set {
            objc_setAssociatedObject(self, &Process.optionsAssociationKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}

public extension Pipe {

    /// Helper method to return String of output from `Pipe` object.
    ///
    /// - Returns: String containing the output of a `Pipe`.
    func output() -> String {
        let data = fileHandleForReading.readDataToEndOfFile()
        guard let outputString = String(data: data, encoding: .utf8)
        else { return "" }
        return outputString
    }
}
