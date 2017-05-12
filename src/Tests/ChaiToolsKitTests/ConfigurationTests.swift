//
//  ConfigurationTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/12/17.
//
//

import XCTest
@testable import ChaiToolsKit

class ConfigurationTests: XCTestCase {

    func testConfiguration() {
        let testConfig = Configuration(value: "TOKEN_VALUE_HERE")
        XCTAssertEqual(testConfig.value, "TOKEN_VALUE_HERE", "Failed to properly set `value` of Configuration object.")
    }
}
