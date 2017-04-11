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
        try? FileOps.defaultOps.removeDirectory(celyDirectory)
        
        super.tearDown()
    }

    func testExecute_successfully() {
        do {
            try testRepo.execute(.clone)
        } catch {
            XCTAssert(false, "Failed to clone test repo")
        }
    }

    func testExecute_failure_alreadyInitialized() {

        do {
            // try cloning after repo is not empty
            try testRepo.execute(.clone)
            try testRepo.execute(.ginit)
        } catch let error {
            guard let errorStatus = error as? GitRepoFailStatus, errorStatus == GitRepoFailStatus.alreadyInitialized else  {
                XCTAssert(false, "Failed to return the error message GitRepoFailStatus.alreadyInitialized, instead returned\(error)")
                return
            }
        }
    }

    func testExecute_failure_nonEmptyRepo() {

        do {
            // try cloning after repo is not empty
            try testRepo.execute(.clone)
            try testRepo.execute(.clone)
        } catch let error {
            guard let errorStatus = error as? GitRepoFailStatus, errorStatus == GitRepoFailStatus.nonEmptyRepo else  {
                XCTAssert(false, "Failed to return the error message GitRepoFailStatus.nonEmptyRepo, instead returned\(error)")
                return
            }
        }
    }

    func testExecute_failure_missingLocalRepo() {
        do {
            // try pulling with no repo in directory
            try testRepo.execute(.pull)
        } catch let error {
            guard let errorStatus = error as? GitRepoFailStatus, errorStatus == GitRepoFailStatus.missingLocalRepo else  {
                XCTAssert(false, "Failed to return the error message GitRepoFailStatus.missingLocalRepo, instead returned\(error)")
                return
            }
        }
    }

    func testExecute_failure_missingRemoteURL() {
        do {
            // try pulling with no repo in directory
            testRepo.remoteURL = nil
            try testRepo.execute(.pull)
        } catch let error {
            guard let errorStatus = error as? GitRepoFailStatus, errorStatus == GitRepoFailStatus.missingRemoteURL else {
                XCTAssert(false, "Failed to return the error message GitRepoFailStatus.missingRemoteURL, instead returned\(error)")
                return
            }
        }
    }
}
