//
//  AndroidBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 3/29/17.
//
//

import Foundation
import ChaiCommandKit

@available(OSX 10.12, *)
class AndroidBootstrap: GenericBootstrap {

    required init() {
        projectJumpStartURL = URL(string: "git@github.com:moldedbits/android-jumpstart.git")
    }

    var projectJumpStartURL: URL!
    var fileOps: FileOps = FileOps.defaultOps

    override func bootstrap(_ projectDirURL: URL, projectName: String) throws {
        let repo = try downloadJumpStart()
        try cloneAndroidJumpStartRepo(repo)
        try moveGitignoreToRoot(repo, projectDirURL: projectDirURL)
        try moveEverythingElse(repo, projectDirURL: projectDirURL)
        try setupReadMeDefaults(projectDirURL, projectName: projectName)
    }

    func downloadJumpStart() throws -> GitRepo {
        let tempDir = try fileOps.createTempDirectory()

        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: projectJumpStartURL)
        MessageTools.state("Androids wear 🚀 boots!")
        return repo
    }

    func cloneAndroidJumpStartRepo(_ repo: GitRepo) throws {

        do {
            MessageTools.state("Setting up Android jumpstart...")
            try repo.clone()
        } catch {
            throw ChaiError.generic(message: "Failed to download jumpstart project. Do you have permission to access it?")
        }
    }

    func moveGitignoreToRoot(_ repo: GitRepo, projectDirURL: URL) throws {
        do {
            try FileManager.default.copyItem(at: repo.localURL.appendingPathComponent(".gitignore"), to: projectDirURL.appendingPathComponent(".gitignore"))
        } catch {
            throw ChaiError.generic(message: "Failed to move .gitingore with error \(error).")
        }
    }

    func moveEverythingElse(_ repo: GitRepo, projectDirURL: URL) throws {

        do {

            let contents = try FileManager.default.contentsOfDirectory(at: repo.localURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let srcDirURL = projectDirURL.appendingPathComponent("src", isDirectory: true)

            for fileURL in contents {
                try FileManager.default.copyItem(at: fileURL, to: srcDirURL.appendingPathComponent(fileURL.lastPathComponent))
            }
            MessageTools.exclaim("Android jumpstart successfully created!")

        } catch {
            throw ChaiError.generic(message: "Failed to move project files with error \(error).")
        }
    }
}
