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
class AndroidBootstrapTests: XCTestCase {

    let tasksToExecute = AndroidBootstrap().bootstrapTasks()

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

}
