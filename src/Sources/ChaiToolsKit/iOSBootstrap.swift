//
//  iOSBootstrap.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/12/17.
//
//

import Foundation

@available(OSX 10.12, *)
struct iOSBootstrap: BootstrapConfig {

    var type: String! {
        return "ios"
    }
    var fileOps: FileOps = FileOps.defaultOps

    init() {}

    func bootstrap(_ projectDirURL: URL) throws {

        try checkIfTemplatesExist()
        try openXcode()
        try xcodeFinishedSettingUp()
        try downloadFastlaneCode()
        try copyFastlaneToDirectory()
        try runFastlaneBootstrap()
    }

    func runAppleScript(arguments: String...) -> Process {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let process = Process(withLaunchPath: "/usr/bin/osascript")
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = arguments
        process.execute()

        return process
    }

    func checkIfTemplatesExist() throws {
        // if not, pull into directory
    }

    func openXcode() throws {
        MessageTools.state("Activating Xcode")
        let process = runAppleScript(arguments: "-e", "tell application \"Xcode\" to activate",
                                     "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}")
        if process.terminationStatus != 0 {
            throw BootstrapCommandError.generic(message: "Failed to Open Xcode")
        }

        MessageTools.state("Successfully opened Xcode.", level: .verbose)
    }

    func xcodeFinishedSettingUp() throws {

    }

    func downloadFastlaneCode() throws {

    }

    func copyFastlaneToDirectory() throws {
        
    }
    
    func runFastlaneBootstrap() throws {
        
    }
}
