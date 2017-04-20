//
//  CommandTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/20/17.
//
//

import XCTest
@testable import ChaiToolsKit

@available(OSX 10.12, *)
class CommandTests: XCTestCase {

    func testCommandInitialization() {
        let launchPath_test = "launchPath_test"
        let arguments_test = ["string1", "string2"]
        let failureMessage_test = "failureMessage_test"
        let successMessage_test = "successMessage_test"
        let preMessage_test = "preMessage_test"

        let testCommand = Command(launchPath: launchPath_test, arguments: arguments_test, preMessage: preMessage_test, successMessage: successMessage_test, failureMessage: failureMessage_test)

        XCTAssertEqual(testCommand.launchPath, launchPath_test)
        XCTAssertEqual(testCommand.arguments, arguments_test)
        XCTAssertEqual(testCommand.failureMessage, failureMessage_test)
        XCTAssertEqual(testCommand.successMessage, successMessage_test)
        XCTAssertEqual(testCommand.preMessage, preMessage_test)
    }
}
