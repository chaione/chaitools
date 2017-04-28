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

/// Applescript ChaiCommands
enum AppleScript: ChaiCommandProtocol {

    case openXcode
    case quitXcode

    static var binary: String {
        return "osascript"
    }

    func arguments() -> ChaiCommandArguments {
        var caseArguments : ChaiCommandArguments {
            switch self {
            case .openXcode:
                return ["-e", "tell application \"Xcode\" to activate", "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}"]

            case .quitXcode:
                return ["-e", "tell application \"Xcode\" to quit"]
            }
        }

        return [type(of: self).binary] + caseArguments
    }
}

@available(OSX 10.12, *)

/// Fastlane ChaiCommands
///
/// - bootstrap: run `fastlane bootstrap`
/// - bootstrapChaiToolsSetup: run `fastlane bootstrap_chai_tools_setup`
/// - lane: Generic case that will allow you to run any lane that is not specified as a case.
enum Fastlane : ChaiCommandProtocol {

    case bootstrap
    case bootstrapChaiToolsSetup
    case lane(String)
    static var binary: String {
        return "fastlane"
    }

    func arguments() -> ChaiCommandArguments {
        var caseArguments : ChaiCommandArguments {
            switch self {
            case .bootstrap:
                return ["bootstrap"]
            case .bootstrapChaiToolsSetup:
                return ["bootstrap_chai_tools_setup"]
            case .lane(let lane):
                return [lane]
            }
        }

        return [type(of: self).binary] + caseArguments
    }

}

@available(OSX 10.12, *)
class iOSBootstrap: BootstrapConfig {

    var fileOps: FileOps = FileOps.defaultOps
    var fastlaneRemoteURL = URL(string: "git@bitbucket.org:chaione/build-scripts.git")
    required init() {}

    func bootstrap(_ projectDirURL: URL) throws {
        try AppleScript.openXcode.run(in: projectDirURL)

        try xcodeFinishedSettingUp()
        try AppleScript.quitXcode.run(in: projectDirURL)
        try restructureXcodeProject(in: projectDirURL)
        let fastlaneRepo = try createFastlaneRepo().clone()
        try addFastlane(fastlaneRepo, toDirectory: projectDirURL)

        let srcDirectory = projectDirURL.subDirectories("src")

        try Fastlane.bootstrapChaiToolsSetup.run(in: srcDirectory)
        // Maybe log output?
        try Fastlane.bootstrap.run(in: srcDirectory)
        // Maybe log output?
        try CommandLine.run(openXcode(inDirectory: srcDirectory), in: srcDirectory)
    }

    func restructureXcodeProject(in directory: URL) throws {
        guard let projectInSrcDirectory = directory.subDirectories("src").firstItem() else {
            throw BootstrapCommandError.generic(message: "Failed to find created Xcode project inside of `src` directory.")
        }

        try CommandLine.run(
            ChaiCommand(
                launchPath: "/bin/mv",
                arguments: ["\(projectInSrcDirectory.path)", "temp"],
                failureMessage: "Failed to move contents inside of project directory inside of `temp` folder inside of root directory."
            ),
            ChaiCommand(
                launchPath: "/bin/rm",
                arguments: ["-rf", "src"],
                failureMessage: "Failed to remove `src` directory."
            ),
            ChaiCommand(
                launchPath: "/bin/mv",
                arguments: ["temp", "src"],
                failureMessage: "Failed to rename `temp` directory to `src`."
            ),
            in: directory)
    }

    func createFastlaneRepo() throws -> GitRepo {
        guard let tempDirectory = fileOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create temp directory to hold 'ChaiOne's Build Script: Fastlane'.")
        }
        let repo = GitRepo(withLocalURL: tempDirectory, andRemoteURL: fastlaneRemoteURL)
        return repo
    }

    func xcodeFinishedSettingUp() throws {
        guard Input.awaitYesNoInput(message: "❓  Has Xcode finished creating a project?") else {
            throw BootstrapCommandError.generic(message: "User failed to create Xcode project.")
        }
    }

    func addFastlane(_ repo: GitRepo, toDirectory directory: URL) throws {
        do {
            let srcDirectory = directory.subDirectories("src")
            try FileManager.default.copyItem(
                at: repo.localURL.subDirectories("ios/fastlane"),
                to: srcDirectory.subDirectories("fastlane")
            )
            try FileManager.default.copyItem(
                at: repo.localURL.subDirectories("ios/Gemfile"),
                to: srcDirectory.file("Gemfile")
            )

            try FileManager.default.copyItem(
                at: repo.localURL.subDirectories("ios/circle.yml"),
                to: directory.file("circle.yml")
            )
            MessageTools.exclaim("Successfully downloaded latest ChaiTools Fastlane scripts")

        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move project files with error \(error).")
        }
    }

    func openXcode(inDirectory directory: URL) -> ChaiCommand {
        var arguments: String {
            guard let xcodeprojPath = directory.firstItem(withFileExtension: "xcodeproj")?.path else {
                return ""
            }

            return xcodeprojPath
        }
        return ChaiCommand(
            launchPath: "/usr/bin/open",
            arguments: [arguments],
            failureMessage: "Failed to open xcodeproj file."
        )
    }
   }

@available(OSX 10.12, *)
extension iOSBootstrap {
    func projectTemplatePath() -> URL {
        return fileOps.expandLocalLibraryPath("Developer/Xcode/Templates/Project Templates")
    }
}

