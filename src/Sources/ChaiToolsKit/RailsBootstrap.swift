//
//  RailsBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 5/23/17.
//
//

import Foundation
import ChaiCommandKit

@available(OSX 10.12, *)
class RailsBootstrap: BootstrapConfig {

    func setUpDirectoryStructure(projectName: String) throws -> URL {
        return FileOps.defaultOps.outputURLDirectory().appendingPathComponent(projectName, isDirectory: true)
    }

    required init() {}

    func bootstrap(_: URL, projectName: String) throws {

        MessageTools.state("Creating new rails project")
        // run ember-cli bootstrap
        try ShellCommand.command(arguments: ["rails", "new", projectName]).run(in: FileOps.defaultOps.outputURLDirectory())
        MessageTools.state("This 🚂 is leaving the station")
    }
}
