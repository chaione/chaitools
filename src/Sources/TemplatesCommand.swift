//
//  TemplatesCommand.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/4/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI

enum TemplateActions: String {
    case install
    case update
    case remove
}

@available(OSX 10.12, *)
struct TemplatesSet {
    var remoteURL: URL
    var localDir: URL
    var repo: GitRepo

    init(repoURL: URL, dir: URL) {
        localDir = dir
        remoteURL = repoURL
        repo = GitRepo(withLocalURL: localDir, andRemoteURL: remoteURL)
    }
}

@available(OSX 10.12, *)
public class TemplatesCommand: Command {

    public var name: String = "templates"
    public var signature: String = "<action>"
    public var shortDescription: String = "Install, update, or remove Xcode templates"

    private var templates: [TemplatesSet] = []

    public init() {

        templates.append(TemplatesSet(repoURL: URL(string: "git@bitbucket.org:chaione/chaitemplates.git")!,
                                      dir: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/File Templates/ChaiOne", isDirectory: true)))
        templates.append(TemplatesSet(repoURL: URL(string: "git@bitbucket.org:chaione/chaixcodetemplates.git")!,
                                      dir: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/Project Templates/ChaiOne", isDirectory: true)))
    }

    public func execute(arguments: CommandArguments) throws {

        guard let action = TemplateActions(rawValue: arguments.requiredArgument("action")) else {
            return print("❗️ \"\(arguments.requiredArgument("action"))\" is not a valid option. Aborting operation.")
        }

        switch action {
        case .install: installTemplates()
        case .update: updateTemplates()
        case .remove: removeTemplates()
        }
    }

    private func installTemplates() {
        print("Attempting to install Xcode templates...")
        var status = true
        for template in templates {
            status = status && template.repo.execute(GitAction.clone)
        }
        if status {
            print("Successfully installed Xcode templates. 🎉")
        } else {
            print("❗️ Xcode template installation failed.")
        }
    }

    private func updateTemplates() {
        print("Attempting to update Xcode templates...")
        var status = true
        for template in templates {
            status = status && template.repo.execute(GitAction.pull)
        }
        if status {
            print("Successfully updated Xcode templates. 🎉")
        } else {
            print("❗️ Xcode template update failed.")
        }
    }

    private func removeTemplates() {

        var status = true
        print("Attempting to remove the templates directory...")
        for template in templates {
            status = status && FileOps.defaultOps.removeDirectory(template.localDir)
        }
        if status {
            print("Successfully removed Xcode templates. 🎉")
        } else {
            print("❗️ Xcode template removal failed.")
        }
    }
}
