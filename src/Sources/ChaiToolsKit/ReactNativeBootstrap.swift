//
//  ReactNativeBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 4/27/17.
//
//

import Foundation
import SwiftCLI

@available(OSX 10.12, *)
class ReactNativeBootstrap: BootstrapConfig {

    required init() {}

    func bootstrap(_ projectDirURL: URL) throws {
        // make sure npm is installed
        // make sure react-native cli is installed
        // make sure tsrn is installed
        // run tsrn
        MessageTools.exclaim("Time to cause a reaction")
    }

}