//
//  main.swift
//  chaitools
//
//  Created by Travis Fischer on 11/3/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import ChaiToolsKit
import SwiftCLI

CLI.setup(name: "chaitools", version: "0.5.1", description: "Brew some awesome apps with ChaiTools")

if #available(OSX 10.12, *) {

    CLI.register(command: TemplatesCommand())
    CLI.register(command: BootstrapCommand())
    CLI.register(command: DevInitCommand())
} else {
    print("macOS 10.12 is required to manage Xcode templates or use bootstrapper.")
}

let result = CLI.go()
exit(result)
