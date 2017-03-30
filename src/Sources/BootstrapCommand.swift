//
//  BootstrapCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 3/27/17.
//
//

import Foundation
import SwiftCLI


protocol BootstrapConfig {
    
    func bootstrap(_ projectDirURL : URL) -> Bool
}

@available(OSX 10.12, *)
enum TechStack : String {
    case android
    
    static let allValues = [android]
    
    /// Returns the BootstrapConfig for the TechStack
    ///
    /// - Returns: BootstrapConfig for the TechStack
    func bootstrapper() -> BootstrapConfig {
        switch self {
        case .android: return AndroidBootstrap()
        }
    }
    
    /// Prints all supported TechStacks
    static func supportedStacks() {
        print("Current supported tech stacks are:")
        for stack in allValues {
            print("- \(stack)")
        }
    }
}

@available(OSX 10.12, *)
class BootstrapCommand: Command {

    var name: String = "bootstrap"
    var signature: String = "[<stack>]"
    var shortDescription: String = "Setup a ChaiOne starter project for the given tech stack"

    private var projectName: String = ""
    
    /// Executes the bootstrap command
    /// Bootstrap takes an optional tech stack arguments and the execution first validates
    /// those arguments before proceeding. Actions that may be performed:
    ///   * generate file structure and base ReadMe
    ///   * specific boot strapping actions for a given tech stack
    ///   * git configuration for the bootstrapped folders
    /// - Parameter arguments: The arguments passed to the command 
    func execute(arguments: CommandArguments) throws {
        
        var bootstrapper : BootstrapConfig?

        print("These boots are made for walking.")
        
        if let stackName = arguments.optionalArgument("stack") {
            
            guard let stack = TechStack(rawValue:stackName) else {
                print("💁  \(stackName) is an unrecognized tech stack.")
                TechStack.supportedStacks()
                print("Please try again with one of those tech stacks.")
                print("See you later, Space Cowboy! 💫")
                return
            }
            
            bootstrapper = stack.bootstrapper()
            
        } else {
            print("💁  chaitools bootstrap works best with a tech stack.")
            TechStack.supportedStacks()

            guard Input.awaitYesNoInput(message: "❓  Should we setup a base project structure?") else {
                print("See you later, Space Cowboy! 💫")
                return
            }
            
            bootstrapper = nil
        }
        
        guard let projectURL = setupDirectoryStructure() else {
            print("Bootstrapper completed with failures. 😭")
            return
        }
        
        if let bootstrapper = bootstrapper {
            guard bootstrapper.bootstrap(projectURL) else {
                print("Bootstrapper completed with failures. 😭")
                return
            }
        }
        
        guard setupReadMeDefaults(projectURL) else {
            print("Bootstrapper completed with failures. 😭")
            return
        }
        
        guard setupGitRepo(projectURL) else {
            print("Bootstrapper completed with failures. 😭")
            return
        }

        print("Boot straps pulled. Time to start walking. 😎")
    }

    /// Setups the expected project folder structure:
    /// |- <project_name>/
    /// |-- docs/
    /// |-- scripts/
    /// |-- src/
    /// |-- tests/
    /// Returns: File URL of the base directory for the project
    func setupDirectoryStructure() -> URL? {

        projectName = Input.awaitInput(message: "❓  What is the name of the project?")

        let projectDirURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent(projectName, isDirectory: true)

        // Do not overwrite existing projects
        guard !FileOps.defaultOps.doesDirectoryExist(projectDirURL) else {
            print("❗️ Project \(projectName) already exists at this location.")
            return nil
        }

        // create directory based on project name
        print("Creating new project directory for project \(projectName)...")
        guard FileOps.defaultOps.ensureDirectory(projectDirURL) else {
            print("❗️ Project directory creation failed.")
            return nil
        }

        print("Successfully created \(projectName) project directory. 🎉")
        FileOps.defaultOps.createSubDirectory("src", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("scripts", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("tests", parent: projectDirURL)
        FileOps.defaultOps.createSubDirectory("docs", parent: projectDirURL)

        return projectDirURL
    }
    
    func setupProjectReadMe(_ projectURL: URL) -> Bool {
        return FileManager.default.createFile(atPath: projectURL.appendingPathComponent("ReadMe.md").path, contents: "#Welcome to the \(projectName) project\nProject created with chaitools bootstrap \(CLI.version).".data(using: .utf8))
    }

    /// Adds a dummy ReadMe.md file to each directory in the default system.
    /// Only add ReadMe if the directory is empty as we want the directory
    /// structure to get checked into git.
    ///
    /// - Parameter projectURL: File path URL for the main project directory.
    // Returns: True if project succeeded or false otherwise
    func setupReadMeDefaults(_ projectURL: URL) -> Bool {

        var status = setupProjectReadMe(projectURL)
        status = status && setupReadMePlaceholders(projectURL.appendingPathComponent("src", isDirectory: true))
        status = status && setupReadMePlaceholders(projectURL.appendingPathComponent("scripts", isDirectory: true))
        status = status && setupReadMePlaceholders(projectURL.appendingPathComponent("tests", isDirectory: true))
        status = status && setupReadMePlaceholders(projectURL.appendingPathComponent("docs", isDirectory: true))

        if !status {
            print("❗️ Failed to create ReadMe files in all project directories.")
        }

        return status
    }
    
    func setupReadMePlaceholders(_ sourceURL: URL) -> Bool {
        do {
            if try FileManager.default.contentsOfDirectory(at: sourceURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles).isEmpty {
                return FileManager.default.createFile(atPath: sourceURL.appendingPathComponent("ReadMe.md").path, contents: "ReadMe added by chaitools bootstrap \(CLI.version) to maintain directory structure.".data(using: .utf8))
            }
        } catch {
            print("Failed to setup ReadMe")
            return false
            
        }
        
        return true
    }

    /// Setups the local git repository.
    ///
    /// - Parameter projectURL: File path URL for the main project directory.
    /// Returns: True if git repo configuration succeeded and false otherwise
    func setupGitRepo(_ projectURL: URL) -> Bool {

        // Run git init
        let repo = GitRepo(withLocalURL: projectURL)

        guard repo.execute(GitAction.ginit) else {
            print("❗️ Failed to initialize local git repo.")
            return false
        }

        guard repo.execute(GitAction.add) else {
            print("❗️ Failed to add code to local git repo.")
            return false
        }

        guard repo.execute(GitAction.commit) else {
            print("❗️ Failed to commit initial code.")
            return false
        }
        print("Successfully setup local git repo for project \(projectName). 🎉")

        // Prompt if remote exists.
        let remoteRepo = Input.awaitInput(message: "❓ Enter the remote repo for \(projectName). Press <enter> to skip.")
        if remoteRepo != "" {
            repo.remoteURL = URL(string: remoteRepo)
            
            guard repo.execute(GitAction.remoteAdd) else {
                print("❗️ Failed to add remote git repo.")
                return false
            }
            
            guard repo.execute(GitAction.push) else {
                print("❗️ Failed to push to remote git repo.")
                return false
            }
            print("Successfully pushed to git remote for project \(projectName). 🎉")
        }
        
        // Setup remote if it doesn't.
        return true
    }
}
