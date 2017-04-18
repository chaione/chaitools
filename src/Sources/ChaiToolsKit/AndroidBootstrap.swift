//
//  AndroidBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 3/29/17.
//
//

import Foundation

@available(OSX 10.12, *)
public class AndroidBootstrap: BootstrapConfig {

    var projectURL: URL!
    var fileOps: FileOps = FileOps.defaultOps
    var type: String! {
        return "android"
    }

    required public init() {
        projectURL = URL(string: "git@github.com:moldedbits/android-jumpstart.git")
    }

    func bootstrap(_ projectDirURL: URL) throws {

        let repo = try downloadJumpStart()
        try cloneAndroidJumpStartRepo(repo)
        try moveGitignoreToRoot(repo)
        try moveEverythingElse(repo)
    }

    func downloadJumpStart() throws -> GitRepo {
        guard let tempDir = fileOps.createTempDirectory() else {
            throw BootstrapCommandError.generic(message: "Failed to create temp directory.")
        }
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: projectURL)
        MessageTools.state("Androids wear 🚀 boots!")
        return repo
    }

    func cloneAndroidJumpStartRepo(_ repo: GitRepo) throws {

        do {
            try repo.execute(GitAction.clone)
            MessageTools.state("Setting up Android jumpstart...")
        } catch {
            throw BootstrapCommandError.generic(message: "Failed to download jumpstart project. Do you have permission to access it?")
        }
    }

    func moveGitignoreToRoot(_ repo: GitRepo) throws {
        do {
            try FileManager.default.copyItem(at: repo.localURL.appendingPathComponent(".gitignore"), to: projectURL.appendingPathComponent(".gitignore"))
        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move .gitingore with error \(error).")
        }
    }

    func moveEverythingElse(_ repo: GitRepo) throws {

        do {

            let contents = try FileManager.default.contentsOfDirectory(at: repo.localURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let srcDirURL = projectURL.appendingPathComponent("src", isDirectory: true)

            for fileURL in contents {
                try FileManager.default.copyItem(at: fileURL, to: srcDirURL.appendingPathComponent(fileURL.lastPathComponent))
            }
            MessageTools.exclaim("Android jumpstart successfully created!")

        } catch {
            throw BootstrapCommandError.generic(message: "Failed to move project files with error \(error).")
        }
    }
}
