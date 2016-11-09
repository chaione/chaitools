//
//  TemplatesCommand.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/4/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI

enum TemplateActions : String {
    case install
    case update
    case remove
}

@available(OSX 10.12, *)
class TemplatesCommand: Command {

    var name: String = "templates"
    var signature: String = "<action>"
    var shortDescription: String = "Install, update, or remove Xcode templates"

    private let templateRepoURL = URL(string: "git@bitbucket.org:chaione/chaitemplates.git")!
    private let templateDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/ChaiOne", isDirectory: true)
    private let repo: GitRepo
    
    init() {
        repo = GitRepo(withLocalURL: templateDirectory, andRemoteURL: templateRepoURL)
    }

    func execute(arguments: CommandArguments) throws {

        guard let action = TemplateActions(rawValue:arguments.requiredArgument("action")) else {
            return print("❗️ \"\(arguments.requiredArgument("action"))\" is not a valid option. Aborting operation.")
        }
        
        switch action {
            case .install: installTemplates()
            case .update: updateTemplates()
            case .remove: removeDirectory()
        }

    }
    
    private func installTemplates() {
        print("Attempting to install Xcode templates...")
        let status = repo.execute(GitAction.clone)
        if status {
            print("Successfully installed Xcode templates. 🎉")
        } else {
            print("❗️ Xcode template installation failed.")
        }
    }
    
    private func updateTemplates() {
        print("Attempting to update Xcode templates...")
        let status = repo.execute(GitAction.pull)
        if status {
            print("Successfully updated Xcode templates. 🎉")
        } else {
            print("❗️ Xcode template update failed.")
        }
    }

    private func removeDirectory() {
        var isDirectory: ObjCBool = ObjCBool(true)

        print("Attempting to remove the templates directory...")

        if FileManager.default.fileExists(atPath: templateDirectory.path, isDirectory: &isDirectory) {
            do {
                try FileManager.default.removeItem(atPath: templateDirectory.path)
                print("Successfully removed the templates directory. 🎉")
            } catch {
                print("❗️ Error removing the directory. \(error)")
            }
        } else {
            print("The templates directory does not exist, so it cannot be removed. 🤔")
        }
    }
}
