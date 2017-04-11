//
//  GitRepoTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/6/17.
//
//

import XCTest
@testable import ChaiToolsKit

@available(OSX 10.12, *)
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
        testRepo = GitRepo(withLocalURL: celyDirectory, andRemoteURL: celyGithubUrl)
        XCTAssertEqual(testRepo.localURL, celyDirectory)
        XCTAssertEqual(testRepo.remoteURL, celyGithubUrl)
    }

    override func tearDown() {
        // remove created directories
        FileOps.defaultOps.removeDirectory(celyDirectory)
        super.tearDown()
    }

    func testExecute_successfully() {

        if testRepo.execute(.clone) != .success {
            XCTAssert(false, "Failed to clone test repo")
            return
        }
    }

    func testExecute_failure_alreadyInitialized() {

        if testRepo.execute(.clone) != .success {
            XCTAssert(false, "Failed to clone test repo")
            return
        }

        let error = testRepo.execute(.ginit)
        XCTAssertEqual(error, .failure(.alreadyInitialized), "Failed to return the error message GitRepoFailStatus.alreadyInitialized, instead returned\(error)")
    }

    func testExecute_failure_nonEmptyRepo() {

        if testRepo.execute(.clone) != .success {
            XCTAssert(false, "Failed to clone test repo")
            return
        }

        let error = testRepo.execute(.clone)
        XCTAssertEqual(error, .failure(.nonEmptyRepo), "Failed to return the error message GitRepoFailStatus.nonEmptyRepo, instead returned\(error)")
    }

    func testExecute_failure_missingLocalRepo() {

        let error = testRepo.execute(.pull)
        XCTAssertEqual(error, .failure(.missingLocalRepo), "Failed to return the error message GitRepoFailStatus.missingLocalRepo, instead returned\(error)")
    }

    func testExecute_failure_missingRemoteURL() {
        testRepo.remoteURL = nil
        let error = testRepo.execute(.pull)
        XCTAssertEqual(error, .failure(.missingRemoteURL), "Failed to return the error message GitRepoFailStatus.missingRemoteURL, instead returned\(error)")
    }
}
