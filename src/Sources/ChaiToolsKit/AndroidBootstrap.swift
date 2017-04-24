//
//  AndroidBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 3/29/17.
//
//

import Foundation

@available(OSX 10.12, *)
class AndroidBootstrap: BootstrapConfig {
    var logger: LoggerProtocol!
    var loggerInput: LoggerInputProtocol

    required init(logger: LoggerProtocol, loggerInput: LoggerInputProtocol) {
        projectURL = URL(string: "git@github.com:moldedbits/android-jumpstart.git")
        self.logger = logger
        self.loggerInput = loggerInput
    }

    var projectURL: URL!
    var fileOps: FileOps = FileOps.defaultOps


    func bootstrap(_ projectDirURL: URL) throws {
        let repo = try downloadJumpStart()
        try cloneAndroidJumpStartRepo(repo)
        try moveGitignoreToRoot(repo, projectDirURL: projectDirURL)
        try moveEverythingElse(repo, projectDirURL: projectDirURL)
    }

    func downloadJumpStart() throws -> GitRepo {
        guard let tempDir = fileOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create temp directory.")
        }
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: projectURL)
        logger.state("Androids wear 🚀 boots!")
        return repo
    }

    func cloneAndroidJumpStartRepo(_ repo: GitRepo) throws {

        do {
            logger.state("Setting up Android jumpstart...")
            try repo.execute(GitAction.clone)
        } catch {
            throw BootstrapCommandError.generic(message: "Failed to download jumpstart project. Do you have permission to access it?")
        }
    }

    func moveGitignoreToRoot(_ repo: GitRepo, projectDirURL: URL) throws {
        do {
            try FileManager.default.copyItem(at: repo.localURL.appendingPathComponent(".gitignore"), to: projectDirURL.appendingPathComponent(".gitignore"))
        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move .gitingore with error \(error).")
        }
    }

    func moveEverythingElse(_ repo: GitRepo, projectDirURL: URL) throws {

        do {

            let contents = try FileManager.default.contentsOfDirectory(at: repo.localURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let srcDirURL = projectDirURL.appendingPathComponent("src", isDirectory: true)

            for fileURL in contents {
                try FileManager.default.copyItem(at: fileURL, to: srcDirURL.appendingPathComponent(fileURL.lastPathComponent))
            }
            logger.exclaim("Android jumpstart successfully created!")

        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move project files with error \(error).")
        }
    }
}
