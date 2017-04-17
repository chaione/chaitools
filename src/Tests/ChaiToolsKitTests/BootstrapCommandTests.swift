//
//  BootstrapCommandTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/11/17.
//
//

import XCTest
@testable import ChaiToolsKit

@available(OSX 10.12, *)
class BootstrapCommandTests: XCTestCase {

    let supportedStackStrings = ["android"]

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBootstrapExecute() {

    }

}

// MARK: - TechStack Tests
@available(OSX 10.12, *)
extension BootstrapCommandTests {
    func testSupportedStacks() {
        XCTAssert(TechStack.rawValues() == ["android"], "TechStack.rawValues() is supposed to equal \(supportedStackStrings)")
    }

    func testSupportedStacksFormmatedString() {
        var formattedSupportedStacksStr = "Current supported tech stacks are:\n"
        formattedSupportedStacksStr.append(supportedStackStrings.map{ "- \($0)\n" }.joined())

        XCTAssertEqual(formattedSupportedStacksStr, TechStack.supportedStacksFormattedString())
    }

    func testTechStackBootstrapper() {
        let androidBootstrap = TechStack.android.bootstrapper()
        XCTAssert(androidBootstrap == AndroidBootstrap())
    }
}
