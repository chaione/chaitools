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
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let process = Process(withLaunchPath: launchPath, currentDirectoryPath: localURL.path)
        process.standardOutput = outputPipe
        process.standardError = errorPipe

        // It would be nice to check if a repo is clean, and then clean if necessary.
        // HINT: Use NSPipe to pass the output of `git status -s` to `wc -l`
        // if (action == .pull) { clean() }

        if !isSafeToProceed(forAction: action) {
            return false
        }

        process.arguments = action.arguments(withRemoteURL: remoteURL)

        MessageTools.state("Running `git \(action.rawValue)`...", level: .verbose)
        process.execute()
        if process.terminationStatus == 0 {
            
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: String.Encoding.utf8)
            MessageTools.state(output!, level: .debug)
            MessageTools.exclaim("`git \(action.rawValue)` was a success!", level: .verbose)
            
            return true
        } else {
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: String.Encoding.utf8)
            MessageTools.state(output!, level: .debug)
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOut = String(data: errorData, encoding: String.Encoding.utf8)
            MessageTools.state(errorOut!, level: .debug)
            
            MessageTools.error("`git \(action.rawValue)` failed! Sad!", level: .verbose)
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
            MessageTools.error("Can't initialize a git repo that's already initialized.", level: .verbose)
            return false
        }

        if remoteURL == nil && (action == .pull || action == .clone) {
            MessageTools.error("Can't perform \(action) when missing remote URL.", level: .verbose)
            return false
        }

        if (action == .pull) && (!localURL.isGitRepo()) {
            MessageTools.state("A git repo can't be updated if it doesn't exist. 🤔", level: .verbose)
            return false
        }

        if (action == .clone) && (!localURL.isEmpty()) {
            MessageTools.error("Can't clone a git repo into a non-empty directory.", level: .verbose)
            return false
        }

        return FileOps.defaultOps.ensureDirectory(localURL)
    }
}
