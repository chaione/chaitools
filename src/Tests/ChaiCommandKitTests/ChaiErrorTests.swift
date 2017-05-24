//
//  ChaiErrorTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/12/17.
//
//

import XCTest
@testable import ChaiCommandKit

class ChaiErrorTests: XCTestCase {

    func testChaiError() {
        let testError = ChaiError(message: "test error")
        XCTAssertEqual(testError.localizedDescription, "test error", "Failed to properly set `localizedDescription`.")
    }

    func testGenericChaiError() {
        let genericError = ChaiError.generic(message: "generic error")
        XCTAssertEqual(genericError.localizedDescription, "generic error", "Failed to properly set `localizedDescription`.")
    }
}
