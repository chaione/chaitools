//
//  GitRepo.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/8/16.
//
//

import Foundation

enum GitAction: String {
    case clone
    case pull
    case ginit = "init"
    case add
    case commit
    case remoteAdd = "remote"
    case push

    func arguments(withRemoteURL url: URL?) -> [String] {
        if let _url = url {
            let urlPath = _url.absoluteString.contains("http") ? _url.absoluteString : _url.path
            switch self {
            case .clone: return [self.rawValue, urlPath, "."]
            case .pull: return [self.rawValue, urlPath]
            case .remoteAdd: return ["remote", "add", "origin", urlPath]
            case .push: return [self.rawValue, "-u", "origin", "master"]
            default: return []
            }

        } else {
            switch self {
            case .ginit: return [self.rawValue]
            case .add: return [self.rawValue, "."]
            case .commit: return [self.rawValue, "-m \"Initial commit by chaitools\""]
            default: return []
            }
        }
    }
}

@available(OSX 10.12, *)
class GitRepo {

    var localURL: URL
    var remoteURL: URL?
    var logger: LoggerProtocol

    private let launchPath = "/usr/bin/git"

    init(withLocalURL localURL: URL, andRemoteURL remoteURL: URL? = nil) {

        self.localURL = localURL
        self.remoteURL = remoteURL
    }

    /// Execute the git action
    ///
    /// - Parameter action: The action to be executed, defined by the GitAction enum
    /// - Returns: True if action succeeded, false otherwise
    func execute(_ action: GitAction) throws {

        // It would be nice to check if a repo is clean, and then clean if necessary.
        // HINT: Use NSPipe to pass the output of `git status -s` to `wc -l`
        // if (action == .pull) { clean() }

        try verifyGitEnvironment(for: action)
        let gitCommand = ChaiCommand(
            launchPath: launchPath,
            arguments: action.arguments(withRemoteURL: remoteURL),
            preMessage: "Running `git \(action.rawValue)`...",
            successMessage: "`git \(action.rawValue)` was a success!",
            failureMessage: "`git \(action.rawValue)` failed!"
        )
        
        try CommandLine.run(gitCommand, in: localURL)
    }

    private func clean() {
        let process = Process(withLaunchPath: launchPath, currentDirectoryPath: localURL.path)
        process.arguments = ["reset", "--hard", "HEAD"]
        process.execute()
    }

    private func verifyGitEnvironment(for action: GitAction) throws {

        if (action == .ginit) && (localURL.isGitRepo()) {
            logger.error("Can't initialize a git repo that's already initialized.", level: .verbose)
            throw GitRepoError.alreadyInitialized
        }

        if remoteURL == nil && (action == .pull || action == .clone) {
            logger.error("Can't perform \(action) when missing remote URL.", level: .verbose)
            throw GitRepoError.missingRemoteURL
        }

        if (action == .pull) && (!localURL.isGitRepo()) {
            logger.state("A git repo can't be updated if it doesn't exist. 🤔", level: .verbose)
            throw GitRepoError.missingLocalRepo
        }

        if (action == .clone) && (!localURL.isEmpty()) {
            logger.error("Can't clone a git repo into a non-empty directory.", level: .verbose)
            throw GitRepoError.nonEmptyRepo
        }

        guard FileOps.defaultOps.ensureDirectory(localURL) else {
            throw GitRepoError.unknown
        }
    }

    func clone() throws -> GitRepo {
        try execute(.clone)
        return self
    }
}
