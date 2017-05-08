//
//  DevInitCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 5/3/17.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI
import ChaiCommandKit

@available(OSX 10.12, *)
public class DevInitCommand: OptionCommand {

    public var name: String = "dev-init"
    public var signature: String = ""
    public var shortDescription: String = "Configure computer with default developer tech stacks"

    public func setupOptions(options: OptionRegistry) {
        MessageTools.addVerbosityOptions(options: options)
    }

    public init() {}

    /// Test whether a binary executable is installed
    ///
    /// - Parameter binary: The name of the executable to test
    /// - Returns: Returns true if the executable exists in the system and false otherwise
    func isInstalled(_ binary: String) -> Bool {
        var isInstalled: Bool = false
        do {
            try ShellCommand.which(binary).run { output in
                isInstalled = output.contains(binary)
            }
            return isInstalled
        } catch {
            return false
        }
    }

    /// Executes the dev-init command
    /// - Parameter arguments: The arguments passed to the command
    public func execute(arguments _: CommandArguments) throws {
        MessageTools.state("Welcome to ChaiOne! Let's setup your machine.", color: .green, level: .silent)

        try HomebrewCommand.update.run { output in
            MessageTools.state(output, level: .debug)
        }

        // Install rbenv (using homebrew)
        MessageTools.state("Setting up rbenv.")
        if !isInstalled("rbenv") {
            MessageTools.state("Installing rbenv...", level: .verbose)
            try HomebrewCommand.install("rbenv").run { output in
                MessageTools.state(output, level: .debug)
            }

            try RbenvCommand.rbinit.run { output in
                MessageTools.state(output, level: .debug)
            }
        } else {
            MessageTools.state("rbenv already installed.", level: .verbose)
        }
        MessageTools.exclaim("rbenv setup complete!")

        // Install node (using homebrew)
        MessageTools.state("Setting up Nodejs.")
        if !isInstalled("node") {
            MessageTools.state("Installing Node...", level: .verbose)

            try HomebrewCommand.install("node").run { output in
                MessageTools.state(output, level: .debug)
            }
        } else {
            MessageTools.state("Node already installed.", level: .verbose)
        }

        MessageTools.exclaim("Node setup complete!")

        MessageTools.state("Setting up yarn.")
        if !isInstalled("yarn") {
            MessageTools.state("Installing yarn...", level: .verbose)
            try HomebrewCommand.install("yarn").run { output in
                MessageTools.state(output, level: .debug)
            }
            MessageTools.state("Please add the following to your shell profile:", color: .yellow, level: .normal)
            MessageTools.state("export PATH=\"$PATH:`yarn global bin`\"", color: .yellow, level: .normal)
        } else {
            MessageTools.state("Yarn already installed.", level: .verbose)
        }

        MessageTools.state("Updating installed packages")
        try HomebrewCommand.upgrade(nil).run { output in
            MessageTools.state(output, level: .debug)
        }

        // Install fixed Ruby version (using rbenv, based on a configuration file)
        MessageTools.state("Installing ruby version \(rubyVersion)")
        if !RbenvCommand.isInstalled(version: rubyVersion) {
            try RbenvCommand.install(rubyVersion).run { output in
                MessageTools.state(output, level: .debug)
            }
            try RbenvCommand.global(rubyVersion).run { output in
                MessageTools.state(output, level: .debug)
            }
        }
        MessageTools.exclaim("Ruby installed!")

        // Install Ember-cli (using yarn)
        MessageTools.state("Installing Ember...")
        if !isInstalled("ember") {
            try YarnCommand.add("ember-cli").run { output in
                MessageTools.state(output, level: .debug)
            }
        }
        MessageTools.exclaim("Ember installed!")

        // Install react (using yarn)
        MessageTools.state("Installing react...")
        if !isInstalled("react") {
            try YarnCommand.add("react").run { output in
                MessageTools.state(output, level: .debug)
            }
        }
        MessageTools.exclaim("React installed!")

        // Install react-native (using yarn)
        MessageTools.state("Installing React Native...")
        if !isInstalled("watchman") {
            try HomebrewCommand.install("watchman").run { output in
                MessageTools.state(output, level: .debug)
            }
        }
        if !isInstalled("react-native") {
            try YarnCommand.add("react-native-cli").run { output in
                MessageTools.state(output, level: .debug)
            }
        }
        MessageTools.state("React Native installed!")

        MessageTools.state("Updating installed packages")
        try YarnCommand.upgrade(nil).run { output in
            MessageTools.state(output, level: .debug)
        }

        // install fastlane
        MessageTools.state("Installing fastlane...")
        try GemCommand.install("fastlane").run { output in
            MessageTools.state(output, level: .debug)
        }
        MessageTools.exclaim("Fastlane installed!")

        // install rails
        MessageTools.state("Installing rails...")
        try GemCommand.install("rails").run { output in
            MessageTools.state(output, level: .debug)
        }
        MessageTools.exclaim("Rails installed!")

        // install bundler
        MessageTools.state("Installing bundler...")
        try GemCommand.install("bundler").run { output in
            MessageTools.state(output, level: .debug)
        }
        MessageTools.exclaim("Bundler installed!")

        // // Install quicklook provisioning (direct download)
        try installQuicklook()
        MessageTools.exclaim("All done! Go forth and make awesome stuff.", level: .silent)
    }

    /// Installs Craig Hockenberry's QuickLook plugin
    ///
    /// - Throws: <#throws value description#>
    func installQuicklook() throws {

        let qlInstallPath = FileOps.defaultOps.expandLocalLibraryPath("QuickLook")

        if !FileManager.default.fileExists(atPath: qlInstallPath.appendingPathComponent("Provisioning.qlgenerator").path) {
            MessageTools.state("Installing Provisioning Quick Look...")
            guard let tempDirectory = FileOps.defaultOps.createTempDirectory() else {
                throw ChaiError.generic(message: "Failed to create temp directory to hold 'QuickLook Plugin'.")
            }

            do {
                // download latest version of provisioning quicklook to temp directory
                try CurlCommand.download(url: .provisioningQuickLook).run(in: tempDirectory)
                // Making sure directory exists inside of `tmp` directory "tmp/swiftformat-<verion>/Provisioning.qlgenerator"
                guard let tempQuickLookPath = tempDirectory.firstItem()?.firstItem()?.file("Provisioning.qlgenerator").path else {
                    throw ChaiError.generic(message: "Failed to find Provisioning Plugin inside of tmp directory.")
                }

                // Copy plugin into "~/Library/QuickLook"
                try ShellCommand.copyDirectory(directory: tempQuickLookPath, to: qlInstallPath.path).run { output in
                    MessageTools.state(output, level: .debug)
                }

                // restart qlmanager
                try ShellCommand.command(arguments: ["qlmanage", "-r"]).run { output in
                    MessageTools.state(output, level: .debug)
                }

                MessageTools.exclaim("QuickLook provisioning plugin installed!")

            } catch {
                throw ChaiError.generic(message: "Failed to copy Provisioning Plugin to project. With error \(error).")
            }
        }
    }
}
