//
//  iOSBootstrapTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/17/17.
//
//

import XCTest
@testable import ChaiToolsKit

@available(OSX 10.12, *)
class iOSBootstrapTests: XCTestCase {

    let tasksToExecute = iOSBootstrap().bootstrapTasks()

    func testTasksToExecute_Names() {

        let names = tasksToExecute.map {$0.name.lowercased()}
        let correctNames = ["check if templates exist in library",
                            "open xcode",
                            "input when xcode finshes",
                            "download fastlane code",
                            "move fastlane to directory",
                            "run fastlane bootstrap"]
        names.enumerated().forEach { (index, name) in
            XCTAssertEqual(name, correctNames[index], "task.name was supposed to equal \(correctNames[index]) not \(name!)")
        }
    }

    func testTasksToExecute_Value() {

        let taskRunnerResult = TaskRunner.execute(tasksToExecute)

        if case Result.success(let data) = taskRunnerResult {
            XCTAssertNil(data)
            return
        }

        XCTAssert(false, "taskRunnerResult returned a failed result.")
    }
}
