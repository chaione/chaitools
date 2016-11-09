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

    func arguments(withRemoteURL url: String) -> [String] {
        switch self {
        case .clone: return [String(describing: self), url, "."]
        case .pull: return [String(describing: self), url]
        }
    }
}

class GitRepo {

    var localURL: URL
    var remoteURL: URL
    private let process: Process
    private let launchPath = "/usr/bin/git"
    private let outputPipe = Pipe()
    private let outputText = String()

    init(withLocalURL localURL: URL, andRemoteURL remoteURL: URL) {
        self.localURL = localURL
        self.remoteURL = remoteURL
        process = Process(withLaunchPath: launchPath, currentDirectoryPath: localURL.path)
    }

    
    /// Execute the git action
    ///
    /// - Parameter action: The action to be executed, defined by the GitAction enum
    /// - Returns: True if action succeeded, false otherwise
    func execute(_ action: GitAction) -> Bool {
        process.arguments = action.arguments(withRemoteURL: remoteURL.path)

        // It would be nice to check if a repo is clean, and then clean if necessary.
        // HINT: Use NSPipe to pass the output of `git status -s` to `wc -l`
        // if (action == .pull) { clean() }
        createLocalURLIfNeeded()

        print("Running `git \(action) \(process.arguments![1])`...")
        process.execute()
        if process.terminationStatus == 0 {
            print("`git \(action)` was a success! 🎉")
            return true
        } else {
            print("❗️`git \(action)` failed! Sad!")
            return false
        }
    }

    // private func isClean() -> Bool { }

    private func clean() {
        let process = Process(withLaunchPath: launchPath, currentDirectoryPath: localURL.path)
        process.arguments = ["reset", "--hard", "HEAD"]
        process.execute()
    }

    private func createLocalURLIfNeeded() {
        var isDirectory: ObjCBool = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: localURL.path, isDirectory: &isDirectory) {
            do {
                print("The local directory does not exist. Attempting to create it...")
                try FileManager.default.createDirectory(at: localURL, withIntermediateDirectories: true)
                print("Successfully created the directory.")
            } catch {
                print("❗️Error creating the directory. \(error)")
            }
        }
    }
}
