//
//  EmberBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 5/10/17.
//
//

import Foundation
import SwiftCLI
import ChaiCommandKit

@available(OSX 10.12, *)
class EmberBootstrap: BootstrapConfig {

    func setUpDirectoryStructure(projectName: String) throws -> URL {
        return FileOps.defaultOps.outputURLDirectory()
    }
    required init() {}


    func bootstrap(_ projectDirURL: URL, projectName: String) throws {

        MessageTools.state("Creating project using ember-cli")
        // run ember-cli bootstrap
        try ShellCommand.command(arguments: ["ember", "new", projectName, "-b", "https://github.com/chaione/chaitools-ember-blueprint.git"]).run(in: FileOps.defaultOps.outputURLDirectory())
        MessageTools.state("Spark a 🔥 with Ember")
    }
}
