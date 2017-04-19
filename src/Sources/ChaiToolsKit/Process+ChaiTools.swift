//
//  Process+ChaiTools.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/9/16.
//
//

import Foundation

extension Process {

    convenience init(withLaunchPath launchPath: String, currentDirectoryPath: String) {
        self.init()
        self.launchPath = launchPath
        self.currentDirectoryPath = currentDirectoryPath
    }

    convenience init(withLaunchPath launchPath: String) {
        self.init()
        self.launchPath = launchPath
    }

    func execute() {
        launch()
        waitUntilExit()
    }
}
