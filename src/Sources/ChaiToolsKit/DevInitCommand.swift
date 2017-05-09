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
        try installHomebrewTools()
        try installRubyVersion()
        try installYarnPackages()
        try installGems()
        try installQuicklook()
        MessageTools.exclaim("All done! Go forth and make awesome stuff.", level: .silent)
    }

    func installRubyVersion() throws {

        try RbenvCommand.rbinit.run { output in
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
    }

    /// Install required Yarn packages
    ///
    /// - Throws: ChaiErrors
    func installYarnPackages() throws {

        try installYarnPackage(package: "ember-cli")
        try installYarnPackage(package: "react")
        try installYarnPackage(package: "react-native-cli")

        MessageTools.state("Updating installed packages")
        try YarnCommand.upgrade(nil).run { output in
            MessageTools.state(output, level: .debug)
        }
    }

    /// Installs the provided Yarn package
    ///
    /// - Parameter package: The Yarn/NPM package to install
    /// - Throws: ChaiError
    func installYarnPackage(package: String) throws {
        MessageTools.state("Installing \(package)...")
        if !isInstalled(package) {
            try YarnCommand.add(package).run { output in
                MessageTools.state(output, level: .debug)
            }
        }
        MessageTools.state("\(package) installed!")
    }

    /// Install required ruby gems
    ///
    /// - Throws: ChaiErrors if any
    func installGems() throws {

        try installGem("fastlane")
        try installGem("rails")
        try installGem("bundler")
    }

    /// Install a ruby gem
    ///
    /// - Parameter gem: Name of gem to install
    /// - Throws: ChaiError
    func installGem(_ gem: String) throws {
        MessageTools.state("Installing \(gem)...")
        try GemCommand.install(gem).run { output in
            MessageTools.state(output, level: .debug)
        }
        MessageTools.exclaim("\(gem) installed!")
    }

    /// Updates homebrew, installs various packages, then upgrades any pre-existing packages
    ///
    /// - Throws: ChaiErrors if things fail
    func installHomebrewTools() throws {
        try HomebrewCommand.update.run { output in
            MessageTools.state(output, level: .debug)
        }

        try installHomebrewFormula(formula: "rbenv")
        try installHomebrewFormula(formula: "node")
        try installHomebrewFormula(formula: "yarn") {
            MessageTools.state("Please add the following to your shell profile:", color: .yellow, level: .normal)
            MessageTools.state("export PATH=\"$PATH:`yarn global bin`\"", color: .yellow, level: .normal)
        }
        try installHomebrewFormula(formula: "watchman")

        MessageTools.state("Updating installed packages")
        try HomebrewCommand.upgrade(nil).run { output in
            MessageTools.state(output, level: .debug)
        }
    }

    /// Installs the given Homebrew formula
    ///
    /// - Parameters:
    ///   - formula: The Homebrew formula to be installed
    ///   - postInstallHook: Optional void block to execute after  installation completes
    /// - Throws: ChaiError
    func installHomebrewFormula(formula: String, postInstallHook: (() -> Void)? = nil) throws {
        MessageTools.state("Setting up \(formula).")
        if !isInstalled(formula) {
            try HomebrewCommand.install(formula).run { output in
                MessageTools.state(output, level: .debug)
            }

            if let hook = postInstallHook {
                hook()
            }

        } else {
            MessageTools.state("\(formula) already installed.", level: .verbose)
        }
        MessageTools.exclaim("\(formula) setup complete!")
    }

    /// Installs Craig Hockenberry's QuickLook plugin
    ///
    /// - Throws: ChaiError if operations fail
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
