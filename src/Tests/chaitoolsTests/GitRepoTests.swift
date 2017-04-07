//
//  GitRepoTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/6/17.
//
//

import XCTest
@testable import ChaiTools

class GitRepoTests: XCTestCase {

    let celyGithubUrl = URL(string: "git@github.com:chaione/Cely.git")
    lazy var celyDirectory: URL = {
        self.localDirectory(childDirectory: "cely")
    }()

    var testRepo: GitRepo!
    var tempDirectoryString: String {
        let infoPlist = Bundle(for: type(of: self)).infoDictionary
        if let debugDirectory = infoPlist?["OutputDirectory"] as? String {
            return debugDirectory
        } else {
            return FileManager.default.currentDirectoryPath
        }
    }

    func localDirectory(childDirectory: String? = nil) -> URL {

        guard let child = childDirectory else {
            return URL(string: "file://\(tempDirectoryString)")!
        }

        return URL(string: "file://\(tempDirectoryString)/\(child)")!
    }

    override func setUp() {
        super.setUp()
        FileOps.defaultOps.createSubDirectory("cely", parent: localDirectory())
        testRepo = GitRepo(withLocalURL: celyDirectory, andRemoteURL: celyGithubUrl)
        XCTAssertEqual(testRepo.localURL, celyDirectory)
        XCTAssertEqual(testRepo.remoteURL, celyGithubUrl)
    }

    override func tearDown() {
        // remove created directories
        let removedDirectory = FileOps.defaultOps.removeDirectory(celyDirectory)
        XCTAssert(removedDirectory)
        super.tearDown()
    }

    func testExecute_successfully() {
        do {
            try testRepo.execute(.clone)
        } catch {
            XCTAssert(false, "Failed to clone test repo")
        }
    }
}
