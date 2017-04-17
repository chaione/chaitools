//
//  iOSBootstrap.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/12/17.
//
//

import Foundation

@available(OSX 10.12, *)
struct iOSBootstrap: BootstrapConfig {

    var type: String! {
        return "ios"
    }
    var fileOps: FileOps = FileOps.defaultOps

    init() {}

    func bootstrapTasks() -> [Task] {

        let copySelf = self


        return [
            Task(name: "Check if templates exist in library")
                .task({ input -> TaskResult in
                    return .success(nil)
                    // if not, pull into directory
                }),

            Task(name: "Open xcode")
                .task({ input -> TaskResult in
                    MessageTools.state("Activating Xcode")
                    let process = copySelf.runAppleScript(arguments: "-e", "tell application \"Xcode\" to activate",
                                                          "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}")
                    if process.terminationStatus == 0 {
                        return .success(nil)
                    } else {
                        // pass string to .unknown that gets the task name. i.e. Failed to "Open Xcode"
                        return .failure(BootstrapCommandError.generic(message: "Failed to Open Xcode"))
                    }
                }).success({
                    MessageTools.state("Successfully opened Xcode.", level: .verbose)
                }),
            Task(name: "Input when xcode finshes")
                .task({ input -> TaskResult in
                    return .success(nil)
                }),
            Task(name: "Download fastlane code")
                .task({ input -> TaskResult in
                    return .success(nil)
                }),
            Task(name: "Move fastlane to directory")
                .task({ input -> TaskResult in
                    return .success(nil)
                }),
            Task(name: "Run fastlane bootstrap")
                .task({ input -> TaskResult in
                    return .success(nil)
                }),
        ]
    }

    func runAppleScript(arguments: String...) -> Process {
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        let process = Process(withLaunchPath: "/usr/bin/osascript")
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        process.arguments = arguments
        process.execute()
        
        return process
    }
}
