//
//  iOSBootstrap.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/12/17.
//
//

import Foundation

struct Task<T> {
    func success(data: T) -> T {
        return data
    }

    func failure<U: ChaiFailStatus>(failStatus: U) -> U {
        return failStatus
    }
}

@available(OSX 10.12, *)
struct iOSBoostrap: BootstrapConfig {
    var projectURL: URL!
    var type: String! {
        return "ios"
    }
    var fileOps: FileOps!

    init(repoUrlString: String! = "") {

    }
    init(repoUrlString: String!, fileOps: FileOps! = FileOps.defaultOps) {
        self.init(repoUrlString: repoUrlString)
        self.fileOps = fileOps
    }

    func bootstrap(_ projectDirURL: URL) -> Bool {

        // check if templates exist in library
            // if not, pull into directory


        // open xcode
        // Spawn a new process before executing as you can only execute them once
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let process = Process(withLaunchPath: "/usr/bin/osascript", currentDirectoryPath: projectDirURL.path)
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = ["/Users/fabian/Development/Apple Scripts/CreateNewXcodeProject.scpt"]
        MessageTools.state("Running iOS Bootstrap")
        process.execute()

        // input when xcode finshes

        // download fastlane code

        // move fastlane to directory 

        // run fastlane bootstrap

        return true
    }
}
