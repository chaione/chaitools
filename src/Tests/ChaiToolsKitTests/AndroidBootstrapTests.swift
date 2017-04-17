//
//  AndroidBootstrapTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/17/17.
//
//

import XCTest
@testable import ChaiToolsKit

@available(OSX 10.12, *)
class DummyAndroid: AndroidBootstrap {
    override func downloadJumpStart(_ input: TaskResult? = nil) -> TaskResult {
        return .success(nil)
    }
    override func cloneAndroidJumpStartRepo(_ input: TaskResult? = nil) -> TaskResult {
        return .success(nil)
    }
    override func moveGitignoreToRoot(_ input: TaskResult? = nil) -> TaskResult {
        return .success(nil)
    }
    override func moveEverythingElse(_ input: TaskResult? = nil) -> TaskResult {
        return .success(nil)
    }
}

@available(OSX 10.12, *)
class AndroidBootstrapTests: XCTestCase {

    let tasksToExecute = DummyAndroid().bootstrapTasks()

    func testTasksToExecute_Names() {

        let names = tasksToExecute.map {$0.name.lowercased()}
        let correctNames = [
            "download jump start to temp folder",
            "clone android jumpstart repo",
            "move .gitignore to root of project",
            "move everything else to src/ folder."
        ]
        names.enumerated().forEach { (index, name) in
            XCTAssertEqual(name, correctNames[index], "task.name was supposed to equal \(correctNames[index]) not \(name!)")
        }
    }

    func testTasksToExecute_Value() {
        let taskRunnerResult = TaskRunner.execute(tasksToExecute)

        if case Result.success(let data) = taskRunnerResult {

            XCTAssertNil(data, "DummyAndroid class was supposed to return `.success(nil)`.")
            return
        }

        XCTAssert(false, "taskRunnerResult returned a failed result.")
    }
}
