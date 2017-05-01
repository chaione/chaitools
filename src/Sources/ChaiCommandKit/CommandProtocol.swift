//
//  ChaiCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/26/17.
//
//

import Foundation

public typealias ChaiCommandArguments = [String]

public enum CommandProtocolError: Error {
    case generic(message: String)

    var localizedDescription: String {
        switch self {
        case .generic(let message):
            return message
        }
    }
}

@available(OSX 10.12, *)
protocol ChaiCommandProtocol {

    /// Returns Array of String that will act as arguments for Process.
    ///
    /// - Returns: Array of Strings
    func arguments() -> ChaiCommandArguments

    /// executable name that will be executed. Example: `which`, `echo`, `ls`
    static var binary: String? { get }
}

@available(OSX 10.12, *)
extension ChaiCommandProtocol {

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
    @discardableResult public func run(in directory :URL) throws -> Process {

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.currentDirectoryPath = directory.path
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = binaryWithArguments()

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        process.execute()

        defer {
            process.output = pipe.output()
        }

        if process.terminationStatus != 0 {
            throw CommandProtocolError.generic(message: pipe.output())
        }

        return process
    }

    /// Executes command.
    ///
    /// - Parameter directory: filePath of directory you will to run command inside of.
    /// - Returns: @discardableResult Process object that contains.
    /// - Throws: `CommandProtocolError` with `.generic` case.
    func run(in directoryPath : String) throws -> Process {
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
