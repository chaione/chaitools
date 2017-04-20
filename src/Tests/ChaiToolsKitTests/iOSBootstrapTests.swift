//
//  iOSBootstrapTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/17/17.
//
//

import XCTest
@testable import ChaiToolsKit

class DummyInput: LoggerInputProtocol {
    static var callCount = 0
    static var inputMessage: String = ""
    func awaitYesNoInput(message: String) -> Bool {
        DummyInput.callCount += 1
        DummyInput.inputMessage = message
        return true
    }
}

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

        DummyInput.callCount = 0
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

    func testBootstrap() {
        let bootstrapper = iOSBootstrap(loggerInput: DummyInput())
        try? bootstrapper.xcodeFinishedSettingUp()
        XCTAssertEqual(DummyInput.callCount, 1, "`iOSBootstrap.xcodeFinishedSettingUp(_:)` should've confirmed with the user if xcode finished creating project.")
    }

    func testOpenXcodeCommand() {
        let bootstrapper = iOSBootstrap()
        let command = bootstrapper.openXcodeCommand()
        XCTAssertEqual(command.launchPath, "/usr/bin/osascript")
        XCTAssertEqual(command.arguments, ["-e", "tell application \"Xcode\" to activate", "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}"])
        XCTAssertEqual(command.preMessage, "Activating Xcode")
        XCTAssertEqual(command.successMessage, "Successfully opened Xcode.")
        XCTAssertEqual(command.failureMessage, "Failed to Open Xcode")
    }

    func testCreateFastlaneRepo() {
        let bootstrapper = iOSBootstrap()
        do {
            let srcDirectory = try tempSrcDirectory()
            let testRepo = try bootstrapper.createFastlaneRepo(in: srcDirectory)

            XCTAssertEqual(testRepo.localURL, srcDirectory)
            XCTAssertEqual(testRepo.remoteURL, bootstrapper.fastlaneRemoteURL)

        } catch {
            XCTAssert(false, "failed to create Fastlane Repo.")
        }
    }

    func testCopyFastlaneToDirectory() {
        let bootstrapper = iOSBootstrap()
        do {
            let srcDirectory = try tempSrcDirectory()
            let testRepo = try bootstrapper.createFastlaneRepo(in: srcDirectory)
            try bootstrapper.copyFastlaneToDirectory(testRepo.clone(), sourceDirectory: srcDirectory)

            let _ = try bootstrapper.sourceDirectory(for: srcDirectory.deletingLastPathComponent())
            let testFaslaneExists = FileOps.defaultOps.ensureDirectory(srcDirectory.subDirectories("fastlane"))
            let testGemfileExists = FileOps.defaultOps.ensureDirectory(srcDirectory.file("Gemfile"))
            XCTAssert(testFaslaneExists, "Failed to copy Fastlane directory into `src project` directory")
            XCTAssert(testGemfileExists, "Failed to copy `Gemfile` file into `src project` directory")
        } catch let e {
            XCTAssert(false, e.localizedDescription)
        }
    }

    func testFastlaneChaiToolsSetupCommand() {
        let bootstrapper = iOSBootstrap()
        let command = bootstrapper.fastlaneChaiToolsSetupCommand()
        XCTAssertEqual(command.launchPath, "/usr/local/bin/fastlane")
        XCTAssertEqual(command.arguments, ["bootstrap_chai_tools_setup"])
        XCTAssertEqual(command.successMessage, "Successfully ran 'fastlane bootstrap_chai_tools_setup'.")
        XCTAssertEqual(command.failureMessage, "Failed to successfully run 'fastlane bootstrap_chai_tools_setup'.")
    }

    func testFastlaneBootstrapCommand() {
        let bootstrapper = iOSBootstrap()
        let command = bootstrapper.fastlaneBootstrapCommand()
        XCTAssertEqual(command.launchPath, "/usr/local/bin/fastlane")
        XCTAssertEqual(command.arguments, ["bootstrap"])
        XCTAssertEqual(command.successMessage, "Successfully ran 'fastlane bootstrap'.")
        XCTAssertEqual(command.failureMessage, "Failed to successfully run 'fastlane bootstrap'.")
    }

    func testProjectTemplatePath() {
        let bootstrapper = iOSBootstrap()
        XCTAssertEqual(bootstrapper.projectTemplatePath(), FileOps.defaultOps.expandLocalLibraryPath("Developer/Xcode/Templates/Project Templates"), "`projectTemplatePath` is supposed to return '~Library/Developer/Xcode/Templates/Project Templates'")
    }
}
