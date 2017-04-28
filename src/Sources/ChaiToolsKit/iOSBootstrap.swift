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

enum Fastlane : CommandProtocol {

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

        // try checkIfTemplatesExist()
        try CommandLine.run(openXcodeCommand(), in: projectDirURL)
        try xcodeFinishedSettingUp()
        guard let tempDirectory = fileOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create temp directory to hold 'ChaiOne's Build Script: Fastlane'.")
        }
        let fastlaneRepo = try createFastlaneRepo(in: tempDirectory).clone()
        let srcDirectory = projectDirURL.subDirectories("src")
        guard let projectInSrcDirectory = srcDirectory.firstItem() else {
            throw BootstrapCommandError.generic(message: "Failed to find created Xcode project inside of `src` directory.")
        }
        try copyFastlaneToDirectory(fastlaneRepo, sourceDirectory: projectInSrcDirectory)
//        try CommandLine.run(fastlaneChaiToolsSetupCommand(), in: projectInSrcDirectory)
        try Fastlane.bootstrapChaiToolsSetup.run(in: projectInSrcDirectory)
        try Fastlane.bootstrap.run(in: projectInSrcDirectory)
//        try CommandLine.run(fastlaneBootstrapCommand(), in: projectInSrcDirectory)
    }

    func openXcodeCommand() -> ChaiCommand {
        return ChaiCommand(
            launchPath: "/usr/bin/osascript",
            arguments: ["-e", "tell application \"Xcode\" to activate", "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}"],
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

    func createFastlaneRepo(in directory: URL) throws -> GitRepo {
        let repo = GitRepo(withLocalURL: directory, andRemoteURL: fastlaneRemoteURL)
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
            MessageTools.exclaim("Successfully downloaded latest ChaiTools Fastlane scripts")

        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move project files with error \(error).")
        }
    }

//    func fastlaneChaiToolsSetupCommand() -> ChaiCommand {
//        return ChaiCommand(
//            launchPath: "/usr/local/bin/fastlane",
//            arguments: ["bootstrap_chai_tools_setup"],
//            successMessage: "Successfully ran 'fastlane bootstrap_chai_tools_setup'.",
//            failureMessage: "Failed to successfully run 'fastlane bootstrap_chai_tools_setup'."
//        )
//    }
//
//    func fastlaneBootstrapCommand() -> ChaiCommand {
//        return ChaiCommand(
//            launchPath: "/usr/local/bin/fastlane",
//            arguments: ["bootstrap"],
//            successMessage: "Successfully ran 'fastlane bootstrap'.",
//            failureMessage: "Failed to successfully run 'fastlane bootstrap'."
//        )
//    }
}

@available(OSX 10.12, *)
extension iOSBootstrap {
    func projectTemplatePath() -> URL {
        return fileOps.expandLocalLibraryPath("Developer/Xcode/Templates/Project Templates")
    }
}

