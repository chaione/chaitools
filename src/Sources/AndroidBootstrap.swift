//
//  AndroidBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 3/29/17.
//
//

import Foundation

@available(OSX 10.12, *)
struct AndroidBootstrap: BootstrapConfig {

    func bootstrap(_ projectDirURL: URL) -> Bool {

        // Download jump start to temp folder
        guard let tempDir = FileOps.defaultOps.createTempDirectory() else {
            MessageTools.error("Failed to create temp directory.", level: .verbose)
            return false
        }
        let jumpstartRepoURL = URL(string: "git@github.com:moldedbits/android-jumpstart.git")
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: jumpstartRepoURL)

        MessageTools.state("Androids wear 🚀  boots!")
        guard repo.execute(GitAction.clone).isSuccessful() else {
            MessageTools.error("Failed to download jumpstart project. Do you have permission to access it?")
            return false
        }

        MessageTools.state("Setting up Android jumpstart...")
        // move .gitignore to root of project
        do {
            try FileManager.default.copyItem(at: tempDir.appendingPathComponent(".gitignore"), to: projectDirURL.appendingPathComponent(".gitignore"))
        } catch {
            MessageTools.error("Failed to move jumpstart files!")
            MessageTools.error("Failed to move .gitingore with error \(error).", level: .verbose)
            return false
        }

        // move everything else to src/ folder.
        do {

            let contents = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let srcDirURL = projectDirURL.appendingPathComponent("src", isDirectory: true)

            for fileURL in contents {
                try FileManager.default.copyItem(at: fileURL, to: srcDirURL.appendingPathComponent(fileURL.lastPathComponent))
            }

        } catch {
            MessageTools.error("Failed to move jumpstart files!")
            MessageTools.error("Failed to move project files with error \(error).", level: .verbose)
            return false
        }
        MessageTools.exclaim("Android jumpstart successfully created!")

        return true
    }
}
