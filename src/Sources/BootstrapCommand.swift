//
//  BootstrapCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 3/27/17.
//
//

import Foundation
import SwiftCLI

class BootstrapCommand: Command {

    var name: String = "bootstrap"
    var signature: String = "[<stack>]"
    var shortDescription: String = "Setup a ChaiOne starter project for the given tech stack"

    func execute(arguments _: CommandArguments) throws {
        print("Those are some nice boots you got.")
    }
}
