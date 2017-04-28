//
//  ChaiCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/26/17.
//
//

import Foundation

public typealias ChaiCommandArguments = [String]

enum CommandProtocolError: Error {
    case generic(message: String)

    var localizedDescription: String {
        switch self {
        case .generic(let message):
            return message
        }
    }
}


@available(OSX 10.12, *)
protocol CommandProtocol {
    func arguments() -> ChaiCommandArguments
    static var binary: String { get }
}

@available(OSX 10.12, *)
extension CommandProtocol {

    @discardableResult func run(in directory :URL) throws -> Process {

        let outputPipe = Pipe()
        let errorPipe = Pipe()

        let process = Process()
        process.launchPath = "/usr/bin/env"
        process.currentDirectoryPath = directory.path
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = arguments()

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

    func run(in directoryPath : String) throws -> Process {
        return try run(in: URL(fileURLWithPath: directoryPath))
    }
}

// MARK: - External class extensions
extension Process {

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

internal extension Pipe {

    func output() -> String {
        let data = fileHandleForReading.readDataToEndOfFile()
        guard let outputString = String(data: data, encoding: .utf8)
            else { return "" }
        return outputString
    }
}
