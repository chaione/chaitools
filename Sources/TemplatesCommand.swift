//
//  TemplatesCommand.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/4/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI

@available(OSX 10.12, *)
class TemplatesCommand: Command {

    var name: String = "templates"
    var signature: String = "<action>"
    var shortDescription: String = "Install, update, or remove Xcode templates"

    private let templateRepoURL = URL(string: "git@bitbucket.org:chaione/chaitemplates.git")!
    private let templateDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/ChaiOne", isDirectory: true)

    func execute(arguments: CommandArguments) throws {
        if arguments.requiredArgument("action") == "remove" {
            try? FileManager.default.removeItem(atPath: templateDirectory.path)
            return
        }

        guard let action = arguments.requiredArgument("action").toGitAction() else {
            return print("\(arguments.requiredArgument("action")) is not a valid option. Aborting operation.")
        }

        let repo = GitRepo(withLocalURL: templateDirectory, andRemoteURL: templateRepoURL)
        repo.execute(action)
    }
}

fileprivate extension String {
    func toGitAction() -> GitAction? {
        switch self {
            case "install": return GitAction.clone
            case "update": return GitAction.pull
            default: return nil
        }
    }
}
