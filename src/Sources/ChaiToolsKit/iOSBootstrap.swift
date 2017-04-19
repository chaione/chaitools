//
//  iOSBootstrap.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/12/17.
//
//

import Foundation
import SwiftCLI

@available(OSX 10.12, *)
struct iOSBootstrap: BootstrapConfig {

    var type: String! {
        return "ios"
    }
    var fileOps: FileOps = FileOps.defaultOps
    var chaiBuildScriptsURL = URL(string: "https://github.com/chaione/Cely.git")

    init() {}

    func bootstrap(_ projectDirURL: URL) throws {

        try checkIfTemplatesExist()
        try openXcode()
        try xcodeFinishedSettingUp()
        let repo = try downloadFastlaneCode()
        try copyFastlaneToDirectory(repo, projectDirURL: projectDirURL)
        try renameFastlaneVariables(projectDirURL)
        try runFastlaneBootstrap(projectDirURL)
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
        if projectTemplatePathWith().isEmpty() {
            try TemplatesCommand().installTemplates()
        }

        if projectTemplatePathWith(subDirectories: "Base").exists(),
            projectTemplatePathWith(subDirectories: "CrossPlatform").exists(),
            projectTemplatePathWith(subDirectories: "Custom").exists(),
            projectTemplatePathWith(subDirectories: "Mac").exists() {
            MessageTools.state("Directory Exists")
        } else {
            MessageTools.error("Missing Directory")
            // if not, pull into directory
        }
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
        guard Input.awaitYesNoInput(message: "❓  Has Xcode finished creating a project?") else {
            throw BootstrapCommandError.generic(message: "User failed to create Xcode project.")
        }

    }

    func downloadFastlaneCode() throws -> GitRepo {
        guard let tempDir = fileOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create temp directory.")
        }
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: chaiBuildScriptsURL)
        MessageTools.state("Downloading Fastlane")

        //==================
        do {
            MessageTools.state("Setting up Fastlane...")
            try repo.execute(GitAction.clone)
            return repo
        } catch {
            throw BootstrapCommandError.generic(message: "Failed to download Fastlane. Do you have permission to access it?")
        }
    }

    func copyFastlaneToDirectory(_ repo: GitRepo, projectDirURL: URL) throws {
        do {

            let projectDirectory = try FileManager.default.contentsOfDirectory(at: projectDirURL.appendingPathComponent("src"), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)[0]
            try FileManager.default.copyItem(at: repo.localURL.appendingPathComponent("ios/fastlane", isDirectory: true), to: projectDirectory.appendingPathComponent("fastlane"))
            try FileManager.default.copyItem(at: repo.localURL.appendingPathComponent("ios/Gemfile"), to: projectDirectory.appendingPathComponent("Gemfile"))
            MessageTools.exclaim("Successfully downloaded latest ChaiTools Fastlane scripts")

        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move project files with error \(error).")
        }
    }

    func renameFastlaneVariables(_ projectDirURL: URL) throws {
        let projectDirectory = try FileManager.default.contentsOfDirectory(at: projectDirURL.appendingPathComponent("src"), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)[0]
        try runFastlane(command: "bootstrap_chai_tools_setup", in: projectDirectory)
    }

    func runFastlaneBootstrap(_ projectDirURL: URL) throws {
        let projectDirectory = try FileManager.default.contentsOfDirectory(at: projectDirURL.appendingPathComponent("src"), includingPropertiesForKeys: nil, options: .skipsHiddenFiles)[0]
        try runFastlane(command: "bootstrap", in: projectDirectory)
    }

    private func runFastlane(command: String, in projectDirectory: URL) throws {
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        let process = Process(withLaunchPath: "/usr/local/bin/fastlane", currentDirectoryPath: projectDirectory.path)
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = [command]
        process.execute()
        
        if process.terminationStatus == 0 {

            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: String.Encoding.utf8)
            MessageTools.state(output!)
            MessageTools.exclaim("Successfully to rename Fastlane placeholder variables.", level: .verbose)

        } else {
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: String.Encoding.utf8)
            MessageTools.state(output!, level: .debug)

            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOut = String(data: errorData, encoding: String.Encoding.utf8)
            MessageTools.state(errorOut!, level: .debug)

            throw GitRepoError.commandFaliure(message: "Failed to rename Fastlane placeholder variables.")
        }
    }
}

@available(OSX 10.12, *)
extension iOSBootstrap {
    func projectTemplatePath() -> URL {
        return fileOps.expandLocalLibraryPath("Developer/Xcode/Templates/Project Templates")
    }

    func projectTemplatePathWith(subDirectories: String...) -> URL {
        let childDirectories = subDirectories.joined(separator: "/")
        let url = projectTemplatePath().appendingPathComponent(childDirectories, isDirectory: true)

        return url
    }
}

