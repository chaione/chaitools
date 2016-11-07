//
//  GitCommand.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/7/16.
//
//

import Foundation

class GitCommand {
    enum GitAction: String {
        case clone = "install"
        case pull = "update"

        func arguments(with url: String) -> [String] {
            switch self {
            case .clone: return [String(describing: self), url, "."]
            case .pull: return [String(describing: self), url]
            }
        }
    }

    private let process = Process()
    var action: GitAction?
    var remoteURL: URL?
    var localURL: URL?

    init() {
        process.launchPath = "/usr/bin/git"
    }

    func execute() {
        createLocalURLIfNeeded()

        var isDirectory: ObjCBool = ObjCBool(true)
        guard let action = action,
            let remoteURL = remoteURL,
            let localURL = localURL,
            FileManager.default.fileExists(atPath: localURL.path, isDirectory: &isDirectory)
            else {
                return print("Git cannot operate without an action, remote URL, and local URL. Aborting operation.")
        }

        if action == .clone {
            guard localURL.isEmpty() else {
                return print("Git cannot clone into a non-empty directory. Aborting operation.")
            }
        }

        process.currentDirectoryPath = localURL.path
        process.arguments = action.arguments(with: remoteURL.absoluteString)

        process.launch()
        process.waitUntilExit()
    }

    private func createLocalURLIfNeeded() {
        guard let localURL = localURL else { return }

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
