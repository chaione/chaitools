//
//  iOSBootstrapTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/17/17.
//
//

import XCTest
@testable import ChaiToolsKit

@available(OSX 10.12, *)
class iOSBootstrapTests: XCTestCase {

    override func setUp() {
        super.setUp()

        do {
            let srcDirectory = try tempSrcDirectory()
            guard FileOps.defaultOps.ensureDirectory(srcDirectory) else {
                throw BootstrapCommandError.generic(message: "Failed to get Temporary src directory.")
            }
        } catch let e {
            XCTAssert(false, e.localizedDescription)
        }
    }

    override func tearDown() {

        do {
            let srcDirectory = try tempSrcDirectory()
            try FileOps.defaultOps.removeDirectory(srcDirectory)
        } catch let e {
            XCTAssert(false, e.localizedDescription)
        }

        super.tearDown()
    }

    func tempSrcDirectory() throws -> URL {
        guard let tempDirectory = FileOps.defaultOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create Temporary directory.")
        }

        if !FileOps.defaultOps.ensureDirectory(tempDirectory.appendingPathComponent("src", isDirectory: true)) {
            FileOps.defaultOps.createSubDirectory("src", parent: tempDirectory)
        }

        return tempDirectory.appendingPathComponent("src", isDirectory: true)
    }
}
