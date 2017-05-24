//
//  ElixirBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 5/24/17.
//
//

import Foundation
import ChaiCommandKit

@available(OSX 10.12, *)
class ElixirBootstrap: BootstrapConfig {

    func setUpDirectoryStructure(projectName: String) throws -> URL {
        return FileOps.defaultOps.outputURLDirectory().appendingPathComponent(projectName, isDirectory: true)
    }

    required init() {}

    func bootstrap(_: URL, projectName: String) throws {

        MessageTools.state("Creating new elixir project")
        try ShellCommand.command(arguments: ["mix", "new", projectName]).run(in: FileOps.defaultOps.outputURLDirectory())
        MessageTools.exclaim("Finished mixing that 🍸!")
    }
}
