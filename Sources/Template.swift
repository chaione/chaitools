//
//  Template.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/4/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI

enum Action: String {
    case install = "install"
    case update = "update"
    case remove = "remove"

    func generate() {
        switch self {
            case .install: print("Install the repo")
            case .update: print("Update the repo")
            case .remove: print("Remove the repo")
        }
    }

    init?(_ string: String) {
        switch string {
            case "-i", "install": self = .install
            case "-u", "update": self = .update
            case "-r", "remove": self = .remove
            default: return nil
        }
    }
}

class GitCommand {
    enum GitAction {
        case clone
        case update
    }

    let process = Process()
    var action: GitAction?
    var remoteURL: URL?
    var localURL: URL?

    init() {
        process.launchPath = "/usr/bin/git"
    }

    func execute() {
        guard let action = action, let remoteURL = remoteURL, let localURL = localURL else { return } // TODO: Do something more obvious

        process.currentDirectoryPath = localURL.path
        process.arguments = [String(describing: action), remoteURL.absoluteString, "."]

        process.launch()
        process.waitUntilExit()
        print(process.terminationStatus)
    }
}

class Template: Command {

    var name: String = "template"
    var signature: String = "<action>"
    var shortDescription: String = "Install, update, or remove Xcode templates"

    private var action: Action?
    private var force: Bool = false

    func setupOptions(options: OptionRegistry) {
        options.add(flags: ["-f", "force"]) {
            self.force = true
        }
    }

    func execute(arguments: CommandArguments) throws {
        let command = GitCommand()
        command.localURL = setDirectory()
        command.action = .clone
        command.remoteURL = URL(string: "https://bitbucket.org/chaione/chaitemplates")
        command.execute()
    }

    func setDirectory() -> URL {
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        let templateDirectory = homeDirectory.appendingPathComponent("Library/Developer/Xcode/Templates/ChaiOne", isDirectory: true)

        // check if ~/Library/Developer/Xcode/Templates/ChaiOne exists
        print("Checking template directory \(templateDirectory.path)")

        if(!FileManager.default.fileExists(atPath: templateDirectory.path)) {

            print("Need to create directory")

            do {
                // If not, create it
                print("Creating template folder")
                try FileManager.default.createDirectory(atPath: templateDirectory.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating template path. Aborting. \(error)")
            }
            print("Must have succeeded")
        } else {
            print("Template folder already exists")
        }

        return templateDirectory
    }
}
