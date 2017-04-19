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
        return URL(fileURLWithPath: "\(FileManager.default.currentDirectoryPath)/cely")
    }()

    var testRepo: GitRepo!
    override func setUp() {
        super.setUp()
        testRepo = GitRepo(withLocalURL: celyDirectory, andRemoteURL: celyGithubUrl)
        XCTAssertEqual(testRepo.localURL, celyDirectory)
        XCTAssertEqual(testRepo.remoteURL, celyGithubUrl)
    }

    override func tearDown() {
        // remove created directories
        try? FileOps.defaultOps.removeDirectory(celyDirectory)
        super.tearDown()
    }

    func testExecute_successfully() {
        XCTAssertNoThrow(try testRepo.execute(.clone), "Failed to clone test repo")
    }

    func testExecute_failure_alreadyInitialized() {

        XCTAssertNoThrow(try testRepo.execute(.clone), "Failed to clone test repo")

        XCTAssertThrowsError(try testRepo.execute(.ginit), "Failed to throw an error") { error in
            if let e = error as? GitRepoError {
                guard case .alreadyInitialized = e else {
                    XCTFail("Failed to return the error message GitRepoError.alreadyInitialized, instead returned\(error)")
                    return
                }
            }
        }
    }

    func testExecute_failure_nonEmptyRepo() {

        XCTAssertNoThrow(try testRepo.execute(.clone), "Failed to clone test repo")

        XCTAssertThrowsError(try testRepo.execute(.clone), "Failed to throw an error") { error in
            if let e = error as? GitRepoError {
                guard case .nonEmptyRepo = e else {
                    XCTFail("Failed to return the error message GitRepoError.nonEmptyRepo, instead returned\(error)")
                    return
                }
            }
        }
    }

    func testExecute_failure_missingLocalRepo() {
        XCTAssertThrowsError(try testRepo.execute(.pull), "Failed to throw an error") { error in
            if let e = error as? GitRepoError {
                guard case .missingLocalRepo = e else {
                    XCTFail("Failed to return the error message GitRepoError.missingLocalRepo, instead returned\(error)")
                    return
                }
            }
        }
    }

    func testExecute_failure_missingRemoteURL() {
        testRepo.remoteURL = nil
        XCTAssertThrowsError(try testRepo.execute(.pull), "Failed to throw an error") { error in
            if let e = error as? GitRepoError {
                guard case .missingRemoteURL = e else {
                    XCTFail("Failed to return the error message GitRepoError.missingRemoteURL, instead returned\(error)")
                    return
                }
            }
        }
    }
}
