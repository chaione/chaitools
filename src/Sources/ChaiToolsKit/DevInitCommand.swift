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

    /// Executes the dev-init command
    /// - Parameter arguments: The arguments passed to the command
    public func execute(arguments: CommandArguments) throws {
        MessageTools.state("Welcome to ChaiOne! Let's setup your machine.", color: .green, level: .silent)
        // Install rbenv (using homebrew)
        MessageTools.state("Installing rbenv...")
        try HomebrewCommand.install("rbenv").run(in: FileManager.default.homeDirectoryForCurrentUser) { output in
            MessageTools.state(output, level: .verbose)
        }
        // Install fixed Ruby version (using rbenv, based on a configuration file)
        // Install node (using homebrew)
        // Install Ember-cli (using npm)
        // Install react (using npm)
        // Install react-native (using npm)
        // Install tsrn (using npm locally)
        // Install quicklook provisioning (direct download)
        MessageTools.exclaim("All done! Go forth and make awesome stuff.", level: .silent) 
    }


}