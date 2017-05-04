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
        MessageTools.exclaim("All done! Go forth and make awesome stuff.", level: .silent) 
    }


}