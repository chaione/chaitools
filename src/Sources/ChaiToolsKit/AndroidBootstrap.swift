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

    func bootstrapTasks() -> [Task] {

        return [

            Task(name: "Download jump start to temp folder")
                .task({ (input) -> TaskResult in
                    return self.downloadJumpStart(input)
                }).success({
                    MessageTools.state("Androids wear 🚀 boots!")
                }),

            Task(name: "Clone Android Jumpstart Repo")
                .task({ (input) -> TaskResult in
                    return self.cloneAndroidJumpStartRepo(input)
                }).success({
                    MessageTools.state("Setting up Android jumpstart...")
                }),

            Task(name: "move .gitignore to root of project")
                .task({ (input) -> TaskResult in
                    self.moveGitignoreToRoot(input)
                }).failure({
                    MessageTools.error("Failed to move .gitingore.", level: .verbose)
                }),

            Task(name: "move everything else to src/ folder.")
                .task({ (input) -> TaskResult in
                    return self.moveEverythingElse(input)
                }).success({
                    MessageTools.exclaim("Android jumpstart successfully created!")
                }).failure({ () in
                    MessageTools.error("Failed to move jumpstart files!")
                })
        ]
    }

    func downloadJumpStart(_ input: TaskResult? = nil) -> TaskResult {
        guard let tempDir = fileOps.createTempDirectory() else {
            return .failure(BootstrapCommandError.generic(message: "Failed to create temp directory."))
        }
        let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: projectURL)
        return .success(repo)
    }

    func cloneAndroidJumpStartRepo(_ input: TaskResult? = nil) -> TaskResult {
        guard let repo = input?.result as? GitRepo
            else { return .failure(GitRepoError.unknown) }

        do {
            try repo.execute(GitAction.clone)
            return .success(repo)
        } catch {
            return .failure(BootstrapCommandError.generic(message: "Failed to download jumpstart project. Do you have permission to access it?"))
        }
    }

    func moveGitignoreToRoot(_ input: TaskResult? = nil) -> TaskResult {
        guard let repo = input?.result as? GitRepo
            else { return .failure(GitRepoError.unknown) }

        do {
            try FileManager.default.copyItem(at: repo.localURL.appendingPathComponent(".gitignore"), to: projectURL.appendingPathComponent(".gitignore"))
            return .success(repo)
        } catch {
            return .failure(BootstrapCommandError.generic(message: "Failed to move .gitingore with error \(error)."))
        }
    }

    func moveEverythingElse(_ input: TaskResult? = nil) -> TaskResult {
        guard let repo = input?.result as? GitRepo
            else { return .failure(GitRepoError.unknown) }

        do {

            let contents = try FileManager.default.contentsOfDirectory(at: repo.localURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let srcDirURL = projectURL.appendingPathComponent("src", isDirectory: true)

            for fileURL in contents {
                try FileManager.default.copyItem(at: fileURL, to: srcDirURL.appendingPathComponent(fileURL.lastPathComponent))
            }

            return .success(nil)

        } catch {
            return .failure(BootstrapCommandError.generic(message: "Failed to move project files with error \(error)."))
        }
    }
}
