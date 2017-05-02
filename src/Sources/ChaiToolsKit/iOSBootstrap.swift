//
//  iOSBootstrap.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/12/17.
//
//

import Foundation
import SwiftCLI
import ChaiCommandKit

@available(OSX 10.12, *)
class iOSBootstrap: BootstrapConfig {

    var fileOps: FileOps = FileOps.defaultOps
    var fastlaneRemoteURL = URL(string: "git@bitbucket.org:chaione/build-scripts.git")
    required init() {}

    func bootstrap(_ projectDirURL: URL) throws {
        try AppleScriptCommand.openXcode.run(in: projectDirURL)

        guard Input.awaitYesNoInput(message: "❓  Has Xcode finished creating a project?") else {
            throw ChaiError.generic(message: "User failed to create Xcode project.")
        }

        try AppleScriptCommand.quitXcode.run(in: projectDirURL)
        try restructureXcodeProject(in: projectDirURL)

        // TODO: Need to redo SwiftFormat code
//        try addSwiftFormatCommand(in: projectDirURL)

        let fastlaneRepo = try createFastlaneRepo().clone()
        try addFastlane(fastlaneRepo, toDirectory: projectDirURL)

        let srcDirectory = projectDirURL.subDirectories("src")
        
        let fastlaneProcess1 = try FastlaneCommand.bootstrapChaiToolsSetup.run(in: srcDirectory)
        MessageTools.exclaim(fastlaneProcess1.output, level: .verbose)
        let fastlaneProcess2 = try FastlaneCommand.bootstrap.run(in: srcDirectory)
        MessageTools.exclaim(fastlaneProcess2.output, level: .verbose)

        try openXcode(inDirectory: srcDirectory)
    }


    /// Method will move all the content inside of the generated folder from Xcode into `src` directory
    ///
    /// - Parameter directory: Projects root directory
    /// - Throws: `BootstrapCommandError`
    func restructureXcodeProject(in directory: URL) throws {
        guard let projectInSrcDirectory = directory.subDirectories("src").firstItem() else {
            throw ChaiError.generic(message: "Failed to find created Xcode project inside of `src` directory.")
        }

        try ShellCommand
            .move(
                file: projectInSrcDirectory.path,
                toPath: "temp")
            .run(in: directory)

        try ShellCommand
            .remove(file: "src")
            .run(in: directory)

        try ShellCommand
            .move(
                file: "temp",
                toPath: "src")
            .run(in: directory)
    }


    /// Creates a local temporary repo to hold fastlane cloned from `build-script` repo.
    ///
    /// - Returns: GitRepo object containing items such as `localPath` to cloned Fastlane repo.
    /// - Throws: `BootstrapCommandError`
    func createFastlaneRepo() throws -> GitRepo {
        guard let tempDirectory = fileOps.createTempDirectory() else {
            throw ChaiError.generic(message: "Failed to create temp directory to hold 'ChaiOne's Build Script: Fastlane'.")
        }
        let repo = GitRepo(withLocalURL: tempDirectory, andRemoteURL: fastlaneRemoteURL)
        return repo
    }

    /// Copy over fastlane to created Xcode project.
    ///
    /// - Parameters:
    ///   - repo: Fastlane repo.
    ///   - directory: Directory that Fastlane will be copied into.
    /// - Throws: `BootstrapCommandError`
    func addFastlane(_ repo: GitRepo, toDirectory directory: URL) throws {
        do {
            let srcDirectory = directory.subDirectories("src")

            try ShellCommand
                .copyDirectory(
                    directory: repo.localURL.subDirectories("ios/fastlane").path,
                    to: srcDirectory.subDirectories("fastlane").path)
                .run(in: directory)

            try ShellCommand
                .copyFile(
                    file: repo.localURL.subDirectories("ios/Gemfile").path,
                    to: srcDirectory.file("Gemfile").path)
                .run(in: directory)

            try ShellCommand
                .copyFile(
                    file: repo.localURL.subDirectories("ios/circle.yml").path,
                    to: directory.file("circle.yml").path)
                .run(in: directory)

            MessageTools.exclaim("Successfully downloaded latest ChaiTools Fastlane scripts")

        } catch {
            throw ChaiError.generic(message: "Failed to move project files with error \(error).")
        }
    }


    /// Opens Xcode with first file item with extension `xcodeproj`
    ///
    /// - Parameter directory: Projects root directory
    /// - Throws: `BootstrapCommandError`
    func openXcode(inDirectory directory: URL) throws {
        // TODO: will need further improvement if we are to handle `.xcworkspaces` as well
        guard let xcodeprojPath = directory.firstItem(withFileExtension: "xcodeproj")?.path else {
            throw ChaiError.generic(message: "Failed to find file with extension `.xcodeproj`")
        }

        try ShellCommand.open(fileName: xcodeprojPath).run(in: directory)
    }

    // TODO: Need to redo this!
    func addSwiftFormatCommand(in directory: URL) throws {
        guard let tempDirectory = fileOps.createTempDirectory() else {
            throw ChaiError.generic(message: "Failed to create temp directory to hold 'SwiftFormat'.")
        }
        let repo = try GitRepo(withLocalURL: tempDirectory, andRemoteURL: URL(string: "git@github.com:nicklockwood/SwiftFormat.git")).clone()

        do {
            MessageTools.exclaim(repo.localURL.path)
            try FileManager.default.copyItem(
                at: repo.localURL.file("CommandLineTool/swiftformat"),
                to: directory.file("scripts/swiftformat")
            )

            MessageTools.exclaim("Successfully downloaded latest SwiftFormat CommandLineTool")

        } catch {
            throw ChaiError.generic(message: "Failed to copy SwiftFormat to project. With error \(error).")
        }
    }
}
