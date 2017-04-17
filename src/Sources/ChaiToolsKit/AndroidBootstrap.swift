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

    var projectURL: URL!
    var fileOps: FileOps = FileOps.defaultOps
    var type: String! {
        return "android"
    }

    init(repoUrlString: String! = "git@github.com:chaione/Cely.git") {
        projectURL = URL(string: repoUrlString)
    }
    func bootstrapTasks(_ projectDirURL: URL) -> [Task] {
        let tempFileOps = fileOps
        let tempProjectURL = projectURL

        return [

            Task(name: "Download jump start to temp folder")
                .task({ (result) -> TaskResult in
                    guard let tempDir = tempFileOps.createTempDirectory() else {
                        return .failure(BootstrapCommandError.generic(message: "Failed to create temp directory."))
                    }
                    let repo = GitRepo(withLocalURL: tempDir, andRemoteURL: tempProjectURL)
                    return .success(repo)
                }).success({
                    MessageTools.state("Androids wear 🚀 boots!")
                }),

            Task(name: "Clone Android Jumpstart Repo")
                .task({ (input) -> TaskResult in
                    guard let repo = input.result as? GitRepo
                        else { return .failure(GitRepoError.unknown) }

                    do {
                        try repo.execute(GitAction.clone)
                        return .success(repo)
                    } catch {
                        return .failure(BootstrapCommandError.generic(message: "Failed to download jumpstart project. Do you have permission to access it?"))
                    }
                }).success({
                    MessageTools.state("Setting up Android jumpstart...")
                }),

            Task(name: "move .gitignore to root of project")
                .task({ (input) -> TaskResult in
                    guard let repo = input.result as? GitRepo
                        else { return .failure(GitRepoError.unknown) }

                    do {
                        try FileManager.default.copyItem(at: repo.localURL.appendingPathComponent(".gitignore"), to: projectDirURL.appendingPathComponent(".gitignore"))
                        return .success(repo)
                    } catch {
                        return .failure(BootstrapCommandError.generic(message: "Failed to move .gitingore with error \(error)."))
                    }
                }).failure({
                    MessageTools.error("Failed to move .gitingore.", level: .verbose)
                }),

            Task(name: "move everything else to src/ folder.")
                .task({ (input) -> TaskResult in
                    guard let repo = input.result as? GitRepo
                        else { return .failure(GitRepoError.unknown) }
                    do {

                        let contents = try FileManager.default.contentsOfDirectory(at: repo.localURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                        let srcDirURL = projectDirURL.appendingPathComponent("src", isDirectory: true)

                        for fileURL in contents {
                            try FileManager.default.copyItem(at: fileURL, to: srcDirURL.appendingPathComponent(fileURL.lastPathComponent))
                        }

                        return .success(nil)

                    } catch {
                        return .failure(BootstrapCommandError.generic(message: "Failed to move project files with error \(error)."))
                    }
                }).success({
                    MessageTools.exclaim("Android jumpstart successfully created!")
                }).failure({ () in
                    MessageTools.error("Failed to move jumpstart files!")
                })
        ]
    }
    func bootstrap(_ projectDirURL: URL) throws {
        let results = TaskRunner.execute(bootstrapTasks(projectDirURL))
        if case Result.failure(let error) = results {
            throw error
        }
    }
}
