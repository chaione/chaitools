//
//  CommandLine.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/19/17.
//
//

import Foundation

@available(OSX 10.12, *)
struct Command {
    let launchPath: String
    let arguments: [String]
    let preMessage: String?
    let successMessage: String?
    let failureMessage: String

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
    static func run(_ command: Command, in projectDirectory: URL) throws {

        if let preMessage = command.preMessage {
            MessageTools.state(preMessage)
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
            MessageTools.state(output!, level: .verbose)
            if let successMessage = command.successMessage {
                MessageTools.exclaim(successMessage, level: .verbose)
            }

        } else {
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: String.Encoding.utf8)
            MessageTools.state(output!, level: .debug)

            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOut = String(data: errorData, encoding: String.Encoding.utf8)
            MessageTools.state(errorOut!, level: .debug)
            throw GitRepoError.commandFaliure(message: command.failureMessage)
        }
    }
}
