//
//  Template.swift
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

    private let templateDirectory = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/ChaiOne", isDirectory: true)

    func execute(arguments: CommandArguments) throws {
        if arguments.requiredArgument("action") == "remove" {
            try? FileManager.default.removeItem(atPath: templateDirectory.path)
            return
        }

        let command = GitCommand()
        command.localURL = templateDirectory
        command.action = GitCommand.GitAction(rawValue: arguments.requiredArgument("action"))
        command.remoteURL = URL(string: "git@bitbucket.org:chaione/chaitemplates.git")
        command.execute()
    }
}
