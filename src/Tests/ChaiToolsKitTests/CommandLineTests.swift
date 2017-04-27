//
//  CommandLineTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/20/17.
//
//

import XCTest
@testable import ChaiToolsKit

@available(OSX 10.12, *)
class CommandLineTests: XCTestCase {

    func testCommandRun() {
        let launchPath_test = "/bin/echo"
        let arguments_test = ["hello"]

        let testCommand = ChaiCommand(launchPath: launchPath_test, arguments: arguments_test, failureMessage: "hi")

        let testProcess = try? CommandLine.runCommand(testCommand, in: FileManager.default.homeDirectoryForCurrentUser)

        XCTAssertEqual(testProcess?.launchPath, launchPath_test)
        XCTAssertEqual(testProcess?.currentDirectoryPath, FileManager.default.homeDirectoryForCurrentUser.path)
        XCTAssertEqual(testCommand.arguments, arguments_test)
    }
}
