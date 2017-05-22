//
//  BootstrapConfig.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/22/17.
//
//

import Foundation

@available(OSX 10.12, *)
protocol BootstrapConfig {
    init()
    func bootstrap(_ projectDirURL: URL, projectName: String) throws
    func setUpDirectoryStructure(projectName: String) throws -> URL
    func setupGitRepo(_ projectURL: URL, projectName: String) throws -> GitRepo
}

@available(OSX 10.12, *)
extension BootstrapConfig {
    func createReadMe(atPath path: URL, content: String) throws {
        guard FileManager.default.createFile(atPath: path.appendingPathComponent("README.md").path, contents: content.data(using: .utf8)) else {
            throw BootstrapCommandError.unknown
        }
    }

    /// Setups the local git repository.
    ///
    /// - Parameter projectURL: File path URL for the main project directory.
    /// - Returns: GitRepo if git repo configuration succeeded
    /// - Throws: Throws if GitRepo fails to configure successfully.
    func setupGitRepo(_ projectURL: URL, projectName: String) throws -> GitRepo {

        // Run git init
        let repo = GitRepo(withLocalURL: projectURL)
        MessageTools.state("local Repo is \(repo.localURL)", color: .blue)
        try repo.execute(.ginit)
        try repo.execute(.add)
        try repo.execute(.commit(message: "Initial commit by chaitools"))

        MessageTools.exclaim("Successfully setup local git repo for project \(projectName).")

        // Prompt if remote exists.
        let remoteRepo = MessageTools.awaitInput(question: "Enter the remote repo for \(projectName). Press <enter> to skip.")
        if remoteRepo != "" {

            try repo.addRemote(urlString: remoteRepo)
            try repo.execute(.push)

            MessageTools.exclaim("Successfully pushed to git remote for project \(projectName).")
        }

        // Setup remote if it doesn't.
        return repo
    }
}
