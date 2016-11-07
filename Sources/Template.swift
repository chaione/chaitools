//
//  Template.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/4/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI

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

    let process = Process()
    var action: GitAction?
    var remoteURL: URL?
    var localURL: URL?

    init() {
        process.launchPath = "/usr/bin/git"
    }

    func execute() {
        guard let action = action, let remoteURL = remoteURL, let localURL = localURL else {
            print("Git cannot operate without an action, remote URL, and local URL.")
            return
        }

        process.currentDirectoryPath = localURL.path
        process.arguments = action.arguments(with: remoteURL.absoluteString)

        if (action == .clone) && (!localURLIsEmpty()) {
            return print("Git cannot clone into a non-empty directory. Aborting operation.")
        }

        process.launch()
        process.waitUntilExit()
    }

    func localURLIsEmpty() -> Bool {
        guard let directoryPath = localURL?.path, let directoryContents = try? FileManager.default.contentsOfDirectory(atPath: directoryPath) else { return false }

        return directoryContents.isEmpty
    }
}

@available(OSX 10.12, *)
class TemplatesCommand: Command {

    var name: String = "templates"
    var signature: String = "<action>"
    var shortDescription: String = "Install, update, or remove Xcode templates"

    func execute(arguments: CommandArguments) throws {
        let command = GitCommand()
        command.localURL = setDirectory()
        command.action = GitCommand.GitAction(rawValue: arguments.requiredArgument("action"))
        command.remoteURL = URL(string: "git@bitbucket.org:chaione/chaitemplates.git")
        command.execute()
    }

    func setDirectory() -> URL {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let templateDirectory = homeDirectory.appendingPathComponent("Library/Developer/Xcode/Templates/ChaiOne", isDirectory: true)

        print("Checking template directory \(templateDirectory.path)")

        if(!FileManager.default.fileExists(atPath: templateDirectory.path)) {

            print("Need to create directory")

            do {
                print("Creating template folder")
                try FileManager.default.createDirectory(atPath: templateDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating template path. Aborting. \(error)")
            }
            print("Must have succeeded. Continuing operation...")
        } else {
            print("Template folder already exists. Continuing operation...")
        }

        return templateDirectory
    }
}
