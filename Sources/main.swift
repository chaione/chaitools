//
//  main.swift
//  chaitools
//
//  Created by Travis Fischer on 11/3/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI

CLI.setup(name: "chaitools", version: "0.2.0", description: "Brew some awesome apps with ChaiTools")

if #available(OSX 10.12, *) {
    CLI.register(command: TemplatesCommand())
} else {
    print("macOS 10.12 is required to manage Xcode templates.")
}

let result = CLI.go()
exit(result)
