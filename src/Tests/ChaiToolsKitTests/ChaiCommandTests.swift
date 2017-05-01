//
//  AppleScriptCommandTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/1/17.
//
//

import XCTest
@testable import ChaiCommandKit


enum TestEnum: ChaiCommand {
    case test1
    case test2
    static var binary: String? {
        return nil
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case .test1:
            return ["echo", "test1"]
        case .test2:
            return ["test2"]
        }
    }
}

@available(OSX 10.12, *)
class ChaiCommandTests: XCTestCase {

    func testChaiCommandRun() {
        do {
            let testProcess = try TestEnum.test1.run(in: FileManager.default.homeDirectoryForCurrentUser)
            XCTAssertEqual(testProcess.output, "test1\n", "Failed to successfully build command to run `echo test1`")
        } catch {
            XCTAssert(false, "Error was throw while trying to run `echo test1`")
        }
    }
}
