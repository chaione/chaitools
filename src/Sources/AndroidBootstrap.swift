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
            print("❗️ Failed to create temp directory")
            return false
        }
        let jumpstartRepoURL = URL(string: "git@github.com:moldedbits/android-jumpstart.git")
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: jumpstartRepoURL)

        print("Androids wear 🚀  boots!")
        guard repo.execute(GitAction.clone) else {
            print("❗️ Failed to download jumpstart project. Do you have permission to access it?")
            return false
        }

        print("Setting up Android jumpstart...")
        // move .gitignore to root of project
        do {
            try FileManager.default.copyItem(at: tempDir.appendingPathComponent(".gitignore"), to: projectDirURL.appendingPathComponent(".gitignore"))
        } catch {
            print("❗️ Failed to move jumpstart files! \(error)")
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
            print("❗️ Failed to move jumpstart files! \(error)")
        }
        print("Android jumpstart successfully created! 🎉")

        return true
    }
}
