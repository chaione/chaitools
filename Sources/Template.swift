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
        action = Action(arguments.requiredArgument("action"))
        
        action?.generate()
    }
}
