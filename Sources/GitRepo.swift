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
        createLocalURLIfNeeded()
    }

    func execute(_ action: GitAction) {
        process.arguments = action.arguments(withRemoteURL: remoteURL.path)

        // It would be nice to check if a repo is clean, and then clean if necessary.
        // HINT: Use NSPipe to pass the output of `git status -s` to `wc -l`
        // if (action == .pull) { clean() }

        process.execute()
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
                try FileManager.default.createDirectory(at: localURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating directory for git repo. \(error)")
            }
        }
    }
}
