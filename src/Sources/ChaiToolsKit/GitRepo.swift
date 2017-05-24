//
//  GitRepo.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/8/16.
//
//

import Foundation
import ChaiCommandKit

enum GitRepoError: ChaiErrorProtocol {
    case alreadyInitialized
    case missingRemoteURL
    case missingLocalRepo
    case nonEmptyRepo
    case invalidProjectName
    case unknown

    var localizedDescription: String {
        switch self {
        case .alreadyInitialized:
            return "Local git repo is already initialized."
        case .missingRemoteURL:
            return "ChaiTools is missing a remote URL."
        case .missingLocalRepo:
            return "ChaiTools is missing a Local Repo."
        case .nonEmptyRepo:
            return "Destination directory needs to be empty"
        case .invalidProjectName:
            return "Remote repo has an invalid name."
        case .unknown:
            return "ChaiTools does not know what happened 😭"
        }
    }
}

@available(OSX 10.12, *)
class GitRepo {

    var localURL: URL
    var remoteURL: URL?

    private let launchPath = "/usr/bin/git"

    init(withLocalURL localURL: URL, andRemoteURL remoteURL: URL? = nil) {

        self.localURL = localURL
        self.remoteURL = remoteURL
    }

    /// Execute the git action
    ///
    /// - Parameter action: The action to be executed, defined by the GitCommand enum
    /// - Returns: True if action succeeded, false otherwise
    func execute(_ action: GitCommand) throws {

        // It would be nice to check if a repo is clean, and then clean if necessary.
        // HINT: Use NSPipe to pass the output of `git status -s` to `wc -l`
        // if (action == .pull) { clean() }

        try verifyGitEnvironment(for: action)

        try action.run(in: localURL)
    }

    func remoteProjectName() throws -> String {
        guard let url = remoteURL?.absoluteString else {
            throw GitRepoError.missingRemoteURL
        }

        guard let projectName = url.matches(for: ChaiURL.repoNameRegex).first else {
            throw GitRepoError.invalidProjectName
        }
        return projectName.lowercased()
    }

    private func clean() {
        let process = Process(withLaunchPath: launchPath, currentDirectoryPath: localURL.path)
        process.arguments = ["reset", "--hard", "HEAD"]
        process.execute()
    }

    private func verifyGitEnvironment(for action: GitCommand) throws {

        switch (action, self) {
        case let (.ginit, selfCopy) where selfCopy.localURL.isGitRepo():
            MessageTools.error("Can't initialize a git repo that's already initialized.", level: .verbose)
            throw GitRepoError.alreadyInitialized
        case let (.pull(_), selfCopy) where selfCopy.remoteURL == nil,
             let (.clone(_), selfCopy) where selfCopy.remoteURL == nil:
            MessageTools.error("Can't perform \(action) when missing remote URL.", level: .verbose)
            throw GitRepoError.missingRemoteURL
        case let (.pull(_), selfCopy) where !selfCopy.localURL.isGitRepo():
            MessageTools.state("A git repo can't be updated if it doesn't exist. 🤔", level: .verbose)
            throw GitRepoError.missingLocalRepo
        case let (.clone(_), selfCopy) where !selfCopy.localURL.isEmpty():
            MessageTools.error("Can't clone a git repo into a non-empty directory.", level: .verbose)
            throw GitRepoError.nonEmptyRepo
        default:
            break
        }

        guard FileOps.defaultOps.ensureDirectory(localURL) else {
            throw GitRepoError.unknown
        }
    }

    @discardableResult func clone() throws -> GitRepo {
        guard let url = remoteURL else {
            throw GitRepoError.missingRemoteURL
        }
        try execute(GitCommand.clone(url: url.absoluteString))
        return self
    }

    @discardableResult func pull() throws -> GitRepo {
        try execute(GitCommand.pull)
        return self
    }

    @discardableResult func addRemote(urlString: String) throws -> GitRepo {
        remoteURL = URL(string: urlString)
        try execute(.remote(.add(urlString)))
        return self
    }
}
