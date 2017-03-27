//
//  BootstrapCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 3/27/17.
//
//

import Foundation
import SwiftCLI

@available(OSX 10.12, *)
class BootstrapCommand: Command {

    var name: String = "bootstrap"
    var signature: String = "[<stack>]"
    var shortDescription: String = "Setup a ChaiOne starter project for the given tech stack"

    private var projectName: String = ""

    func execute(arguments _: CommandArguments) throws {
        print("These boots are made for walking.")
        if let projectURL = setupDirectoryStructure() {
            setupReadMeDefaults(projectURL)
        }
    }

    /// Setups the expected project folder structure:
    /// |- <project_name>/
    /// |-- docs/
    /// |-- scripts/
    /// |-- src/
    /// |-- tests/
    func setupDirectoryStructure() -> URL? {

        projectName = Input.awaitInput(message: "❓ What is the name of the project?")

        let projectDirURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(projectName)

        // Do not overwrite existing projects
        if FileOps.defaultOps.doesDirectoryExist(projectDirURL) {
            print("❗️ Project \(projectName) already exists at this location.")
        } else {

            // create directory based on project name
            print("Creating new project directory for project \(projectName)...")
            let success = FileOps.defaultOps.ensureDirectory(projectDirURL)

            if success {
                print("Project directory created successfully.")
            } else {
                print("❗️ Project directory creation failed.")
            }

            FileOps.defaultOps.createSubDirectory("src", parent: projectDirURL)
            FileOps.defaultOps.createSubDirectory("scripts", parent: projectDirURL)
            FileOps.defaultOps.createSubDirectory("tests", parent: projectDirURL)
            FileOps.defaultOps.createSubDirectory("docs", parent: projectDirURL)

            return projectDirURL
        }

        return nil
    }

    /// Adds a dummy ReadMe.md file to each directory in the default system.
    ///
    /// - Parameter projectURL: File path URL for the main project directory.
    func setupReadMeDefaults(_ projectURL: URL) {

        FileManager.default.createFile(atPath: projectURL.appendingPathComponent("ReadMe.md").path, contents: "#Welcome to the \(projectName) project".data(using: .utf8))

        FileManager.default.createFile(atPath: projectURL.appendingPathComponent("src/ReadMe.md").path, contents: "Project source code goes here.".data(using: .utf8))
        FileManager.default.createFile(atPath: projectURL.appendingPathComponent("scripts/ReadMe.md").path, contents: "Project external scripts go here.".data(using: .utf8))
        FileManager.default.createFile(atPath: projectURL.appendingPathComponent("tests/ReadMe.md").path, contents: "Automated tests goes here.".data(using: .utf8))
        FileManager.default.createFile(atPath: projectURL.appendingPathComponent("docs/ReadMe.md").path, contents: "Project documentation goes here.".data(using: .utf8))
    }
}
