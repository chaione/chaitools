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
enum TechStack: String, Iteratable {
    case android
    case ios
    /// Returns the BootstrapConfig for the TechStack
    ///
    /// - Returns: BootstrapConfig for the TechStack
    func bootstrapper() -> BootstrapConfig {
        switch self {
        case .android: return AndroidBootstrap()
        case .ios: return iOSBootstrap()
        }
    }

    /// return all supported TechStacks
    static func supportedStacksFormattedString() -> String {
        var supportedStacksStr = "Current supported tech stacks are:\n"
        let stacks = rawValues().map{ "- \($0)\n" }.joined()
        supportedStacksStr.append(stacks)

        return supportedStacksStr
    }
}

@available(OSX 10.12, *)
public class BootstrapCommand: OptionCommand {

    public var name: String = "bootstrap"
    public var signature: String = "[<stack>]"
    public var shortDescription: String = "Setup a ChaiOne starter project for the given tech stack"

    public func setupOptions(options: OptionRegistry) {
        MessageTools.addVerbosityOptions(options: options)
    }

    private var projectName: String = ""

    public init() {}

    /// Executes the bootstrap command
    /// Bootstrap takes an optional tech stack arguments and the execution first validates
    /// those arguments before proceeding. Actions that may be performed:
    ///   * generate file structure and base ReadMe
    ///   * specific boot strapping actions for a given tech stack
    ///   * git configuration for the bootstrapped folders
    /// - Parameter arguments: The arguments passed to the command
    public func execute(arguments: CommandArguments) throws {

        do {
            var bootstrapper: BootstrapConfig?

            MessageTools.state("These boots are made for walking.", level: .silent)

            if let stackName = arguments.optionalArgument("stack") {

                guard let stack = TechStack(rawValue: stackName) else {
                    MessageTools.instruct("\(stackName) is an unrecognized tech stack.",
                        level: .silent)
                    MessageTools.state(TechStack.supportedStacksFormattedString())
                    MessageTools.state("Please try again with one of those tech stacks.")
                    MessageTools.state("See you later, Space Cowboy! 💫", level: .silent)
                    return
                }

                bootstrapper = stack.bootstrapper()

            } else {
                MessageTools.instruct("chaitools bootstrap works best with a tech stack.", level: .silent)
                MessageTools.state(TechStack.supportedStacksFormattedString())

                guard Input.awaitYesNoInput(message: "❓  Should we setup a base project structure?") else {
                    MessageTools.state("See you later, Space Cowboy! 💫", level: .silent)
                    return
                }

                bootstrapper = nil
            }

            let projectURL = try setupDirectoryStructure()

            if let bootstrapper = bootstrapper {
                try bootstrapper.bootstrap(projectURL)
            }
            
            try setupReadMeDefaults(projectURL)
            try setupGitRepo(projectURL)
            
            MessageTools.state("Boot straps pulled. Time to start walking. 😎", level: .silent)
        } catch let error {
            MessageTools.error(error.description)
        }
    }

    /// Setups the expected project folder structure:
    /// |- <project_name>/
    /// |-- docs/
    /// |-- scripts/
    /// |-- src/
    /// |-- tests/
    /// Returns: File URL of the base directory for the project
    func setupDirectoryStructure() throws -> URL {

        projectName = Input.awaitInput(message: "❓  What is the name of the project?")

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

        MessageTools.exclaim("Successfully created \(projectName) project directory.")
        FileOps.defaultOps.createSubDirectory("src", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("scripts", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("tests", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("docs", parent: projectDirURL)

        return projectDirURL
    }

    func setupProjectReadMe(_ projectURL: URL) throws {
        guard FileManager.default.createFile(atPath: projectURL.appendingPathComponent("ReadMe.md").path, contents: "#Welcome to the \(projectName) project\nProject created with chaitools bootstrap \(CLI.version).".data(using: .utf8)) else {
            throw BootstrapCommandError.unknown
        }
    }

    /// Adds a dummy ReadMe.md file to each directory in the default system.
    /// Only add ReadMe if the directory is empty as we want the directory
    /// structure to get checked into git.
    ///
    /// - Parameter projectURL: File path URL for the main project directory.
    // Returns: True if project succeeded or false otherwise
    func setupReadMeDefaults(_ projectURL: URL) throws {
        try setupProjectReadMe(projectURL)
        try setupReadMePlaceholders(projectURL.appendingPathComponent("src", isDirectory: true))
        try setupReadMePlaceholders(projectURL.appendingPathComponent("scripts", isDirectory: true))
        try setupReadMePlaceholders(projectURL.appendingPathComponent("tests", isDirectory: true))
        try setupReadMePlaceholders(projectURL.appendingPathComponent("docs", isDirectory: true))
    }

    func setupReadMePlaceholders(_ sourceURL: URL) throws {
        do {
            if try FileManager.default.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).isEmpty {
                guard FileManager.default.createFile(atPath: sourceURL.appendingPathComponent("ReadMe.md").path,
                                                     contents: "ReadMe added by chaitools bootstrap \(CLI.version) to maintain directory structure.".data(using: .utf8)) else
                {
                    throw BootstrapCommandError.unknown
                }
            }
        } catch {
            MessageTools.error("Failed to setup ReadMe in \(sourceURL)", level: .verbose)
            MessageTools.error("Error creating ReadMe: \(error)", level: .debug)
            throw BootstrapCommandError.generic(message: "Failed to setup ReadMe in \(sourceURL)")
        }
    }

    /// Setups the local git repository.
    ///
    /// - Parameter projectURL: File path URL for the main project directory.
    /// Returns: True if git repo configuration succeeded and false otherwise
    func setupGitRepo(_ projectURL: URL) throws {

        // Run git init
        let repo = GitRepo(withLocalURL: projectURL)
        MessageTools.state("local Repo is \(repo.localURL)")
        try repo.execute(GitAction.ginit)
        try repo.execute(GitAction.add)
        try repo.execute(GitAction.commit)

        MessageTools.exclaim("Successfully setup local git repo for project \(projectName).")

        // Prompt if remote exists.
        let remoteRepo = Input.awaitInput(message: "❓  Enter the remote repo for \(projectName). Press <enter> to skip.")
        if remoteRepo != "" {
            repo.remoteURL = URL(string: remoteRepo)

            try repo.execute(GitAction.remoteAdd)
            try repo.execute(GitAction.push)

            MessageTools.exclaim("Successfully pushed to git remote for project \(projectName).")
        }

        // Setup remote if it doesn't.
    }
}
