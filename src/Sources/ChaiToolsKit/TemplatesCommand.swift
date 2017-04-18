//
//  TemplatesCommand.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/4/16.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation
import SwiftCLI

enum TemplateActions: String {
    case install
    case update
    case remove
}

@available(OSX 10.12, *)
struct TemplatesSet {
    var remoteURL: URL
    var localDir: URL
    var repo: GitRepo

    init(repoURL: URL, dir: URL) {
        localDir = dir
        remoteURL = repoURL
        repo = GitRepo(withLocalURL: localDir, andRemoteURL: remoteURL)
    }
}

@available(OSX 10.12, *)
public class TemplatesCommand: OptionCommand {

    public var name: String = "templates"
    public var signature: String = "<action>"
    public var shortDescription: String = "Install, update, or remove Xcode templates"

    public func setupOptions(options: OptionRegistry) {
        MessageTools.addVerbosityOptions(options: options)
    }

    private var templates: [TemplatesSet] = []

    public init() {

        templates.append(TemplatesSet(repoURL: URL(string: "git@bitbucket.org:chaione/chaitemplates.git")!,
                                      dir: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/File Templates/ChaiOne", isDirectory: true)))
        templates.append(TemplatesSet(repoURL: URL(string: "git@bitbucket.org:chaione/chaixcodetemplates.git")!,
                                      dir: FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/Project Templates/ChaiOne", isDirectory: true)))
    }

    public func execute(arguments: CommandArguments) throws {

        guard let action = TemplateActions(rawValue: arguments.requiredArgument("action")) else {
            return MessageTools.error("\"\(arguments.requiredArgument("action"))\" is not a valid option. Aborting operation.", level: .silent)
        }

        switch action {
        case .install: try installTemplates()
        case .update: try updateTemplates()
        case .remove: try removeTemplates()
        }
    }

    func installTemplates() throws {
        MessageTools.state("Attempting to install Xcode templates...")
        for template in templates {
            try template.repo.execute(GitAction.clone)
        }
        try copyOverXcodeProjectTemplates()
        MessageTools.exclaim("Successfully installed Xcode templates.")
    }

    private func copyOverXcodeProjectTemplates() throws {
        let xcodeTemplatePath = URL(fileURLWithPath: "Applications/Xcode.app/Contents/Developer/Library/Xcode/Templates/Project Templates/ChaiOne", isDirectory: true)
        do {

            let contents = try FileManager.default.contentsOfDirectory(at: xcodeTemplatePath, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            let srcDirURL = FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library/Developer/Xcode/Templates/Project Templates/ChaiOne", isDirectory: true)

            for fileURL in contents {
                try FileManager.default.copyItem(at: fileURL, to: srcDirURL.appendingPathComponent(fileURL.lastPathComponent))
            }
            MessageTools.exclaim("Successfully copied over Xcode DefaultProject Templates")

        } catch {
            throw FileOpsError.generic(message: "Failed to copy over Xcode default Project Templates. Error: \(error).")
        }

    }

    private func updateTemplates() throws {
        MessageTools.state("Attempting to update Xcode templates...")
        // Checks if all is true
        for template in templates {
            try template.repo.execute(GitAction.pull)
        }
        MessageTools.exclaim("Successfully updated Xcode templates.")
    }

    private func removeTemplates() throws {
        MessageTools.state("Attempting to remove the templates directory...")
        for template in templates {
            try FileOps.defaultOps.removeDirectory(template.localDir)
        }
        MessageTools.exclaim("Successfully removed Xcode templates.")
    }
}
