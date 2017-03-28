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
        if let urlPath = url?.path {
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

    private let launchPath = "/usr/bin/git"
    private let outputPipe = Pipe()
    private let outputText = String()

    init(withLocalURL localURL: URL, andRemoteURL remoteURL: URL? = nil) {

        self.localURL = localURL
        self.remoteURL = remoteURL
    }

    /// Execute the git action
    ///
    /// - Parameter action: The action to be executed, defined by the GitAction enum
    /// - Returns: True if action succeeded, false otherwise
    func execute(_ action: GitAction) -> Bool {

        // Spawn a new process before executing as you can only execute them once
        let process = Process(withLaunchPath: launchPath, currentDirectoryPath: localURL.path)

        // It would be nice to check if a repo is clean, and then clean if necessary.
        // HINT: Use NSPipe to pass the output of `git status -s` to `wc -l`
        // if (action == .pull) { clean() }

        if !isSafeToProceed(forAction: action) {
            return false
        }

        process.arguments = action.arguments(withRemoteURL: remoteURL)

        print("Running `git \(action.rawValue)`...")
        process.execute()
        if process.terminationStatus == 0 {
            print("`git \(action.rawValue)` was a success! 🎉")
            return true
        } else {
            print("❗️ `git \(action.rawValue)` failed! Sad!")
            return false
        }
    }

    // private func isClean() -> Bool { }

    private func clean() {
        let process = Process(withLaunchPath: launchPath, currentDirectoryPath: localURL.path)
        process.arguments = ["reset", "--hard", "HEAD"]
        process.execute()
    }

    private func isSafeToProceed(forAction action: GitAction) -> Bool {

        if (action == .ginit) && (localURL.isGitRepo()) {
            print("❗️ Can't initialize a git repo that's already initialized.")
            return false
        }

        if remoteURL == nil && (action == .pull || action == .clone) {
            print("❗️ Can't perform \(action) when missing remote URL.")
            return false
        }

        if (action == .pull) && (!localURL.isGitRepo()) {
            print("A git repo can't be updated if it doesn't exist. 🤔")
            return false
        }

        if (action == .clone) && (!localURL.isEmpty()) {
            print("❗️ Can't clone a git repo into a non-empty directory.")
            return false
        }

        return FileOps.defaultOps.ensureDirectory(localURL)
    }
}
