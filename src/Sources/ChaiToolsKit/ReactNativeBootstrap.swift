//
//  ReactNativeBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 4/27/17.
//
//

import Foundation
import SwiftCLI
import ChaiCommandKit

@available(OSX 10.12, *)
class ReactNativeBootstrap: BootstrapConfig {

    required init() {}

    func setUpDirectoryStructure(projectName: String) throws -> URL {
        return FileOps.defaultOps.outputURLDirectory().appendingPathComponent(projectName, isDirectory: true)
    }

    func bootstrap(_: URL, projectName: String) throws {
        MessageTools.state("Creating new React Native project with TypeScript support.")
        try ShellCommand.command(arguments: ["tsrn", projectName]).run(in: FileOps.defaultOps.outputURLDirectory()) { output in
            MessageTools.state(output, level: .debug)
        }
        MessageTools.exclaim("Time to cause a reaction")
    }
}
