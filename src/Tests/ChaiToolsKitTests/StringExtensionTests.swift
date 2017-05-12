//
//  StringExtensionTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/10/17.
//
//

import XCTest
@testable import ChaiToolsKit

struct RegexTestObj {
    var testString: String
    var shouldMatch: [String]
}

class StringExtensionTests: XCTestCase {

    func testMatch() {
        let testStrings = [
            RegexTestObj(testString: "git@github.com:chaione/Cely.git", shouldMatch: ["Cely"]),
            RegexTestObj(testString: "https://github.com/chaione/chaitools.git", shouldMatch: ["chaitools"]),
            RegexTestObj(testString: "https://github.com/chaione/alamo-fire.git", shouldMatch: ["alamo-fire"]),
            RegexTestObj(testString: "git@github.com:chaione/Cely.git https://github.com/chaione/chaitools.git", shouldMatch: ["Cely", "chaitools"]),
            RegexTestObj(testString: "https://github.com/chaione/alamo-fire", shouldMatch: []),
            RegexTestObj(testString: "git@github.com:chaione/.git", shouldMatch: []),

        ]

        testStrings.forEach { obj in
            let extractedStrings = obj.testString.matches(for: ChaiURL.repoNameRegex)
            XCTAssert(extractedStrings == obj.shouldMatch, "`extractedStrings` should've equaled `\(obj.shouldMatch)`")
        }

    }
}
