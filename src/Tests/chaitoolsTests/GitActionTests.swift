//
//  GitActionTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/4/17.
//
//

import XCTest
@testable import ChaiTools
import Foundation

class GitActionTests: XCTestCase {

    let dummyURL = FileOps.defaultOps.outputURLDirectory()

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testClone() {
        if let action = GitAction(rawValue: "clone") {
            XCTAssertEqual(action, .clone, "The rawValue value `clone` does not return GitAction.clone")

            let nilURLArguments = action.arguments(withRemoteURL: nil)
            XCTAssertEqual(nilURLArguments, [], "nilURLArguments from GitAction.clone was supposed to return []")

            let urlArguments = action.arguments(withRemoteURL: dummyURL)
            let correctArguments = ["clone", dummyURL.path, "."]
            XCTAssertEqual(urlArguments, correctArguments, "urlArguments from GitAction.clone was supposed to return (correctArguments)")
        } else {
            XCTFail("The rawValue value `clone` does not return GitAction.clone")
        }
    }

    func testPull() {
        if let action = GitAction(rawValue: "pull") {
            XCTAssertEqual(action, .pull, "The rawValue value `pull` does not return GitAction.pull")

            let nilURLArguments = action.arguments(withRemoteURL: nil)
            XCTAssertEqual(nilURLArguments, [], "nilURLArguments from GitAction.pull was supposed to return []")

            let urlArguments = action.arguments(withRemoteURL: dummyURL)
            let correctArguments = ["pull", dummyURL.path]
            XCTAssertEqual(urlArguments, correctArguments, "urlArguments from GitAction.pull was supposed to return (correctArguments)")
        } else {
            XCTFail("The rawValue value `pull` does not return GitAction.pull")
        }
    }

    func testGinit() {
        if let action = GitAction(rawValue: "init") {
            XCTAssertEqual(action, .ginit, "The rawValue value `ginit` does not return GitAction.ginit")

            let nilURLArguments = action.arguments(withRemoteURL: nil)
            XCTAssertEqual(nilURLArguments, [GitAction.ginit.rawValue], "nilURLArguments from GitAction.ginit was supposed to return []")

            let urlArguments = action.arguments(withRemoteURL: dummyURL)
            let correctArguments: [String] = []
            XCTAssertEqual(urlArguments, correctArguments, "urlArguments from GitAction.ginit was supposed to return (correctArguments)")
        } else {
            XCTFail("The rawValue value `ginit` does not return GitAction.ginit")
        }
    }

    func testAdd() {
        if let action = GitAction(rawValue: "add") {
            XCTAssertEqual(action, .add, "The rawValue value `add` does not return GitAction.add")

            let nilURLArguments = action.arguments(withRemoteURL: nil)
            XCTAssertEqual(nilURLArguments, [GitAction.add.rawValue, "."], "nilURLArguments from GitAction.add was supposed to return \([GitAction.add, "."])")

            let urlArguments = action.arguments(withRemoteURL: dummyURL)
            let correctArguments: [String] = []
            XCTAssertEqual(urlArguments, correctArguments, "urlArguments from GitAction.add was supposed to return (correctArguments)")
        } else {
            XCTFail("The rawValue value `add` does not return GitAction.add")
        }
    }

    func testCommit() {
        if let action = GitAction(rawValue: "commit") {
            XCTAssertEqual(action, .commit, "The rawValue value `commit` does not return GitAction.commit")

            let nilURLArguments = action.arguments(withRemoteURL: nil)
            XCTAssertEqual(nilURLArguments, [GitAction.commit.rawValue, "-m \"Initial commit by chaitools\""], "nilURLArguments from GitAction.commit was supposed to return \([GitAction.commit, "-m \"Initial commit by chaitools\""])")

            let urlArguments = action.arguments(withRemoteURL: dummyURL)
            let correctArguments: [String] = []
            XCTAssertEqual(urlArguments, correctArguments, "urlArguments from GitAction.commit was supposed to return (correctArguments)")
        } else {
            XCTFail("The rawValue value `commit` does not return GitAction.commit")
        }
    }

    func testRemoteAdd() {
        if let action = GitAction(rawValue: "remote") {
            XCTAssertEqual(action, .remoteAdd, "The rawValue value `remoteAdd` does not return GitAction.remoteAdd")

            let nilURLArguments = action.arguments(withRemoteURL: nil)
            XCTAssertEqual(nilURLArguments, [], "nilURLArguments from GitAction.remoteAdd was supposed to return []")

            let urlArguments = action.arguments(withRemoteURL: dummyURL)
            let correctArguments: [String] = ["remote", "add", "origin", dummyURL.path]
            XCTAssertEqual(urlArguments, correctArguments, "urlArguments from GitAction.remoteAdd was supposed to return (correctArguments)")
        } else {
            XCTFail("The rawValue value `remoteAdd` does not return GitAction.remoteAdd")
        }
    }

    func testPush() {
        if let action = GitAction(rawValue: "push") {
            XCTAssertEqual(action, .push, "The rawValue value `push` does not return GitAction.push")

            let nilURLArguments = action.arguments(withRemoteURL: nil)
            XCTAssertEqual(nilURLArguments, [], "nilURLArguments from GitAction.push was supposed to return []")

            let urlArguments = action.arguments(withRemoteURL: dummyURL)
            let correctArguments = ["push", "-u", "origin", "master"]
            XCTAssertEqual(urlArguments, correctArguments, "urlArguments from GitAction.push was supposed to return (correctArguments)")
        } else {
            XCTFail("The rawValue value `push` does not return GitAction.push")
        }
    }
}
