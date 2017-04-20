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
class iOSBootstrap: BootstrapConfig {

    var fileOps: FileOps = FileOps.defaultOps
    var fastlaneRemoteURL = URL(string: "git@bitbucket.org:chaione/build-scripts.git")
    var logger: LoggerProtocol
    var loggerInput: LoggerInputProtocol

     required init(logger: LoggerProtocol = Logger(), loggerInput: LoggerInputProtocol = LoggerInput()) {
        self.logger = logger
        self.loggerInput = loggerInput
    }

    func sourceDirectory(for projectDirURL: URL) throws -> URL {
        guard let sourceDirectory = projectDirURL.subDirectories("src").firstItem() else {
            throw BootstrapCommandError.generic(message: "Failed to locate 'src' directory inside of '\(projectDirURL.path)'")
        }

        return sourceDirectory
    }

    func bootstrap(_ projectDirURL: URL) throws {
        let srcDirectory = try sourceDirectory(for: projectDirURL)
        // try checkIfTemplatesExist()
        try CommandLine.run(openXcodeCommand(), in: projectDirURL)
        try xcodeFinishedSettingUp()
        guard let tempDirectory = fileOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create temp directory to hold 'ChaiOne's Build Script: Fastlane'.")
        }
        let fastlaneRepo = try createFastlaneRepo(in: tempDirectory).clone()
        try copyFastlaneToDirectory(fastlaneRepo, sourceDirectory: srcDirectory)
        try CommandLine.run(fastlaneChaiToolsSetupCommand(), in: srcDirectory)
        try CommandLine.run(fastlaneBootstrapCommand(), in: srcDirectory)
    }

//    func checkIfTemplatesExist() throws {
//        // TODO: Still need to do this!!!!
//        if projectTemplatePath().isEmpty() {
//            try TemplatesCommand().installTemplates()
//        }
//
//        if projectTemplatePath().subDirectories("Base").exists(),
//            projectTemplatePath().subDirectories("CrossPlatform").exists(),
//            projectTemplatePath().subDirectories("Custom").exists(),
//            projectTemplatePath().subDirectories("Mac").exists() {
//            messageTool.state("Directory Exists")
//        } else {
//            messageTool.error("Missing Directory")
//            // if not, pull into directory
//        }
//    }

    func openXcodeCommand() -> Command {
        return Command(
            launchPath: "/usr/bin/osascript",
            arguments: ["-e", "tell application \"Xcode\" to activate", "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}"],
            preMessage: "Activating Xcode",
            successMessage: "Successfully opened Xcode.",
            failureMessage: "Failed to Open Xcode"
        )
    }

    func xcodeFinishedSettingUp() throws {
        guard loggerInput.awaitYesNoInput(message: "❓  Has Xcode finished creating a project?") else {
            throw BootstrapCommandError.generic(message: "User failed to create Xcode project.")
        }
    }

    func createFastlaneRepo(in tempDirectory: URL) throws -> GitRepo {
        let repo = GitRepo(withLocalURL: tempDirectory, andRemoteURL: fastlaneRemoteURL)
        return repo
    }

    func copyFastlaneToDirectory(_ repo: GitRepo, sourceDirectory: URL) throws {
        do {
            try FileManager.default.copyItem(
                at: repo.localURL.subDirectories("ios/fastlane"),
                to: sourceDirectory.subDirectories("fastlane")
            )
            try FileManager.default.copyItem(
                at: repo.localURL.subDirectories("ios/Gemfile"),
                to: sourceDirectory.file("Gemfile")
            )
            logger.exclaim("Successfully downloaded latest ChaiTools Fastlane scripts")

        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move project files with error \(error).")
        }
    }

    func fastlaneChaiToolsSetupCommand() -> Command {
        return Command(
            launchPath: "/usr/local/bin/fastlane",
            arguments: ["bootstrap_chai_tools_setup"],
            successMessage: "Successfully ran 'fastlane bootstrap_chai_tools_setup'.",
            failureMessage: "Failed to successfully run 'fastlane bootstrap_chai_tools_setup'."
        )
    }

    func fastlaneBootstrapCommand() -> Command  {
        return Command(
            launchPath: "/usr/local/bin/fastlane",
            arguments: ["bootstrap"],
            successMessage: "Successfully ran 'fastlane bootstrap'.",
            failureMessage: "Failed to successfully run 'fastlane bootstrap'."
        )
    }
}

@available(OSX 10.12, *)
extension iOSBootstrap {
    func projectTemplatePath() -> URL {
        return fileOps.expandLocalLibraryPath("Developer/Xcode/Templates/Project Templates")
    }
}

