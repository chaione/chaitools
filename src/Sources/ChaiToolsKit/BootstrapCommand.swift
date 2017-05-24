//
//  BootstrapCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 3/27/17.
//
//

import Foundation
import SwiftCLI
import ChaiCommandKit

enum BootstrapCommandError: ChaiErrorProtocol {
    case unrecognizedTechStack
    case projectAlreadyExistAtLocation(projectName: String)
    case unknown

    var localizedDescription: String {
        switch self {
        case .unrecognizedTechStack:
            return "ChaiTools did not recognize Tech Stack"
        case let .projectAlreadyExistAtLocation(projectName):
            return "Project \(projectName) already exists at this location."
        case .unknown:
            return "ChaiTools does not know what happened 😭"
        }
    }
}

@available(OSX 10.12, *)
enum TechStack: String, Iteratable {
    case android
    case ios
    case ember
    case rails
    case reactNative = "react-native"
    /// Returns the BootstrapConfig for the TechStack
    ///
    /// - Returns: BootstrapConfig for the TechStack
    func bootstrapper() -> BootstrapConfig {
        switch self {
        case .android: return AndroidBootstrap()
        case .ios: return iOSBootstrap()
        case .reactNative: return ReactNativeBootstrap()
        case .ember: return EmberBootstrap()
        case .rails: return RailsBootstrap()
        }
    }

    /// return all supported TechStacks
    static func supportedStacksFormattedString() -> String {
        var supportedStacksStr = "Current supported tech stacks are:\n"
        let stacks = rawValues().map { "- \($0)\n" }.joined()
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
            var bootstrapper: BootstrapConfig!

            MessageTools.state("These boots are made for walking.", color: .green, level: .silent)

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

                guard MessageTools.awaitYesNoInput(question: "Should we setup a base project structure?") else {
                    MessageTools.state("See you later, Space Cowboy! 💫", level: .silent)
                    return
                }

                bootstrapper = GenericBootstrap()
            }

            let projectName = createProjectName()

            let projectURL = try bootstrapper.setUpDirectoryStructure(projectName: projectName)

            MessageTools.state("Dir: \(projectURL.path)", level: .debug)

            try bootstrapper.bootstrap(projectURL, projectName: projectName)
            let repo = try bootstrapper.setupGitRepo(projectURL, projectName: projectName)
            if let _ = repo.remoteURL {
                // User set a remote URL
                try setupCircleCi(for: repo)
            }
            MessageTools.state("Boot straps pulled. Time to start walking. 😎", color: .green, level: .silent)

        } catch let error as ChaiErrorProtocol {
            MessageTools.error(error.localizedDescription)
        } catch let error {
            MessageTools.error(error.localizedDescription)
        }
    }

    func createProjectName() -> String {
        let projectName = MessageTools.awaitInput(question: "What is the name of the project?")
        return projectName
    }

    func setupCircleCi(for repo: GitRepo) throws {
        let projectName = try repo.remoteProjectName()
        MessageTools.exclaim(ChaiURL.followCircleCi(project: projectName).url)
        try CurlCommand.post(url: ChaiURL.followCircleCi(project: projectName)).run { output in
            MessageTools.state(output, color: .cyan)
        }
    }
}
