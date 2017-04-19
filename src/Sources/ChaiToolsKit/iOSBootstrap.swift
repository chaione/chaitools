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

    var type: String! { return "ios" }

    var fileOps: FileOps = FileOps.defaultOps
    var chaiBuildScriptsURL = URL(string: "git@bitbucket.org:chaione/build-scripts.git")

    init() {}

    func sourceDirectory(for projectDirURL: URL) throws -> URL {
        guard let sourceDirectory = projectDirURL.subDirectories("src").firstItem() else {
            throw BootstrapCommandError.generic(message: "Failed to locate 'src' directory inside of '\(projectDirURL.path)'")
        }

        return sourceDirectory
    }

    func bootstrap(_ projectDirURL: URL) throws {
        let srcDirectory = try sourceDirectory(for: projectDirURL)
        try checkIfTemplatesExist()
        try CommandLine.run(openXcodeCommand(), in: projectDirURL)
        try xcodeFinishedSettingUp()
        let fastlaneRepo = try createFastlaneRepo().clone()
        try copyFastlaneToDirectory(fastlaneRepo, sourceDirectory: srcDirectory)
        try CommandLine.run(fastlaneChaiToolsSetupCommand(), in: srcDirectory)
        try CommandLine.run(fastlaneBootstrapCommand(), in: srcDirectory)
    }

    func checkIfTemplatesExist() throws {
        // TODO: Still need to do this!!!!
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

    func openXcodeCommand() -> Command {
        return Command(
            launchPath: "/usr/bin/osascript",
            command: "-e", "tell application \"Xcode\" to activate", "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}",
            preMessage: "Activating Xcode",
            successMessage: "Successfully opened Xcode.",
            failureMessage: "Failed to Open Xcode"
        )
    }

    func xcodeFinishedSettingUp() throws {
        guard Input.awaitYesNoInput(message: "❓  Has Xcode finished creating a project?") else {
            throw BootstrapCommandError.generic(message: "User failed to create Xcode project.")
        }
    }

    func createFastlaneRepo() throws -> GitRepo {
        guard let tempDir = fileOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create temp directory to hold 'ChaiOne's Build Script: Fastlane'.")
        }
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: chaiBuildScriptsURL)
        return repo
    }

    func copyFastlaneToDirectory(_ repo: GitRepo, sourceDirectory: URL) throws {
        do {
            try FileManager.default.copyItem(
                at: repo.localURL.subDirectories("ios/fastlane", isDirectory: true),
                to: sourceDirectory.subDirectories("fastlane")
            )
            try FileManager.default.copyItem(
                at: repo.localURL.subDirectories("ios/Gemfile"),
                to: sourceDirectory.subDirectories("Gemfile")
            )
            MessageTools.exclaim("Successfully downloaded latest ChaiTools Fastlane scripts")

        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move project files with error \(error).")
        }
    }

    func fastlaneChaiToolsSetupCommand() -> Command {
        return Command(
            launchPath: "/usr/local/bin/fastlane",
            command: "bootstrap_chai_tools_setup",
            successMessage: "Successfully ran 'fastlane bootstrap_chai_tools_setup'.",
            failureMessage: "Failed to successfully run 'fastlane bootstrap_chai_tools_setup'."
        )
    }

    func fastlaneBootstrapCommand() -> Command  {
        return Command(
            launchPath: "/usr/local/bin/fastlane",
            command: "bootstrap",
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

    func projectTemplatePathWith(subDirectories: String...) -> URL {
        let childDirectories = subDirectories.joined(separator: "/")
        let url = projectTemplatePath().subDirectories(childDirectories, isDirectory: true)

        return url
    }
}

