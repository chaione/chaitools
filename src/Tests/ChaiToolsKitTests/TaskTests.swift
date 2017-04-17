//
//  TaskTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/17/17.
//
//

import XCTest
@testable import ChaiToolsKit

class TaskTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testTasksToExecute_Names() {
        let tasks = tasksToExecute()
        let names = tasks.map {$0.name}
        let correctNames = ["name 1", "name 2", "name 3", "name 4", "name 5"]
        names.enumerated().forEach { (index, name) in
            XCTAssertEqual(name, correctNames[index], "task.name was supposed to equal \(correctNames[index]) not \(name!)")
        }
    }

    func testTasksToExecute_Value() {
        let tasks = tasksToExecute()
        let taskRunnerResult = TaskRunner.execute(tasks)

        if case Result.success(let data) = taskRunnerResult {
            guard let value = data as? String else {
                XCTAssert(false, "Failed to return as string from result.")
                return
            }

            let correctStr = "success 1, 2, 3, 4, 5. FINISHED!!!!"
            XCTAssertEqual(value, correctStr, "Failed to pass value from task to task.")
            return
        }

        XCTAssert(false, "taskRunnerResult returned a failed result.")
    }

    func tasksToExecute() -> [Task] {

        let tasks : [Task] = [
            Task(name: "name 1")
                .task({ input -> TaskResult in
                    return .success("success 1")
                }).success({
                    print("Test 1 Success.")
                }).failure({
                    print("!!!!Test 1 Failure.")
                }),
            Task(name: "name 2")
                .task({ input -> TaskResult in
                    guard let str = input.result as? String else {
                        return .failure(TaskError.unknown)
                    }
                    return .success("\(str), 2")
                }).success({
                    print("Test 2 Success.")
                }).failure({
                    print("!!!!Test 2 Failure.")
                }),
            Task(name: "name 3")
                .task({ input -> TaskResult in
                    guard let str = input.result as? String else {
                        return input
                    }
                    return .success("\(str), 3")
                }).success({
                    print("Test 3 Success.")
                }).failure({
                    print("!!!!Test 3 Failure.")
                }),
            Task(name: "name 4")
                .task({ input -> TaskResult in
                    guard let str = input.result as? String else {
                        return .failure(TaskError.unknown)
                    }
                    return .success("\(str), 4")
                }).success({
                    print("Test 4 Success.")
                }).failure({
                    print("!!!!Test 4 Failure.")
                }),
            Task(name: "name 5")
                .task({ input -> TaskResult in
                    guard let str = input.result as? String else {
                        return .failure(TaskError.unknown)
                    }
                    return .success("\(str), 5. FINISHED!!!!")
                }).success({
                    print("Test 5 Success.")
                }).failure({
                    print("!!!!Test 5 Failure.")
                })
        ]
        
        return tasks
    }
}
