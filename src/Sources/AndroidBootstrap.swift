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
 
    func bootstrap(_ projectDirURL : URL) -> Bool {
        
        // Download jump start to temp folder
        guard let tempDir = FileOps.defaultOps.createTempDirectory() else {
            print("❗️ Failed to create temp directory")
            return false
        }
        print("Temp directory: \(tempDir)") // temporary for debugging. Remove before PR.
        let jumpstartRepoURL = URL(string:"git@github.com:moldedbits/android-jumpstart.git")
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: jumpstartRepoURL)
        
        print("Androids wear 🚀  boots!")
        guard repo.execute(GitAction.clone) else {
            print("❗️ Failed to download jumpstart project. Do you have permission to access it?")
           return false
        }
        
        // move .gitignore to root of project
        
        // move everything else to src/ folder.
        
        return true
    }
}
