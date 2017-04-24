//
//  CommandLine.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/19/17.
//
//

import Foundation

@available(OSX 10.12, *)
struct ChaiCommand {
    let launchPath: String
    let arguments: [String]
    let preMessage: String?
    let successMessage: String?
    let failureMessage: String


    /// instantiate a new ChiCommand
    ///
    /// - Parameters:
    ///   - launchPath: Sets the receiver’s executable.
    ///   - arguments: Sets the command arguments that should be used to launch the executable.
    ///   - preMessage: Message to be displayed before command is executed.
    ///   - successMessage: Message to be displayed if command is successfully executed.
    ///   - failureMessage: Message to be displayed if command fails to execute successfully.
    init(launchPath: String, arguments: [String], preMessage: String? = nil, successMessage: String? = nil, failureMessage: String) {
        self.launchPath = launchPath
        self.arguments = arguments
        self.successMessage = successMessage
        self.preMessage = preMessage
        self.failureMessage = failureMessage
    }
}

@available(OSX 10.12, *)
struct CommandLine {

    /// static method used to run a `ChaiCommand`
    ///
    /// - Parameters:
    ///   - command: `ChaiCommand` Object
    ///   - projectDirectory: Directory where Command will be executed
    /// - Returns: `Process` object
    /// - Throws: `CommandLineError`
    static var logger: LoggerProtocol!

    @discardableResult static func run(_ command: ChaiCommand, in projectDirectory: URL, withLogger logger: LoggerProtocol = Logger()) throws -> Process {

        if let preMessage = command.preMessage {
            logger.state(preMessage)
        }

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        let process = Process(withLaunchPath: command.launchPath, currentDirectoryPath: projectDirectory.path)
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = command.arguments
        process.execute()

        if process.terminationStatus == 0 {

            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: String.Encoding.utf8)
            logger.state(output!, level: .verbose)
            if let successMessage = command.successMessage {
                logger.exclaim(successMessage, level: .verbose)
            }

        } else {
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: String.Encoding.utf8)
            logger.state(output!, level: .debug)

            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOut = String(data: errorData, encoding: String.Encoding.utf8)
            logger.state(errorOut!, level: .debug)
            throw GitRepoError.commandFaliure(message: command.failureMessage)
        }

        return process
    }
}
