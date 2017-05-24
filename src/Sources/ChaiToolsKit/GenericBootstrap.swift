//
//  GenericBootstrap.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/22/17.
//
//

import Foundation
import SwiftCLI
import ChaiCommandKit

@available(OSX 10.12, *)
class GenericBootstrap: BootstrapConfig {

    required init() {}

    func bootstrap(_ projectDirURL: URL, projectName: String) throws {
    }

    /// Setups the expected project folder structure:
    /// |- <project_name>/
    /// |-- docs/
    /// |-- scripts/
    /// |-- src/
    /// |-- tests/
    /// Returns: File URL of the base directory for the project
    func setUpDirectoryStructure(projectName: String) throws -> URL {

        let projectDirURL = FileOps.defaultOps.outputURLDirectory().appendingPathComponent(projectName, isDirectory: true)

        // Do not overwrite existing projects
        guard !FileOps.defaultOps.doesDirectoryExist(projectDirURL) else {
            throw BootstrapCommandError.projectAlreadyExistAtLocation(projectName: projectName)
        }

        // create directory based on project name
        MessageTools.state("Creating new project directory for project \(projectName)...")

        guard FileOps.defaultOps.ensureDirectory(projectDirURL) else {
            throw BootstrapCommandError.unknown
        }

        MessageTools.exclaim("Successfully created \(projectName) project directory.", color: .blue)
        FileOps.defaultOps.createSubDirectory("src", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("scripts", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("tests", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("docs", parent: projectDirURL)

        return projectDirURL
    }

    /// Adds a dummy ReadMe.md file to each directory in the default system.
    /// Only add ReadMe if the directory is empty as we want the directory
    /// structure to get checked into git.
    ///
    /// - Parameter projectURL: File path URL for the main project directory.
    func setupReadMeDefaults(_ projectURL: URL, projectName: String) throws {
        try createReadMe(
            atPath: projectURL,
            content: "#Welcome to the \(projectName) project\nProject created with chaitools bootstrap \(CLI.version)."
        )

        try ["src", "scripts", "tests", "docs"].forEach { subDirectory in
            try createReadMe(
                atPath: projectURL.subDirectories(subDirectory),
                content: "ReadMe added by chaitools bootstrap \(CLI.version) to maintain directory structure."
            )
        }
    }
}
