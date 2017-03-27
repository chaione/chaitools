//
//  ProvisioningCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 12/6/16.
//
//

import Foundation
import SwiftCLI

enum ProvisioningActions: String {
    case install
    case enable
}

@available(OSX 10.12, *)
class ProvisioningCommand: Command {

    var name: String = "quicklook"
    var signature: String = "<action>"
    var shortDescription: String = "Install Provisioning Quick Look plugin or enable copying from the plugin"

    func execute(arguments: CommandArguments) throws {

        guard let action = ProvisioningActions(rawValue: arguments.requiredArgument("action")) else {
            return print("❗️ \"\(arguments.requiredArgument("action"))\" is not a valid option. Aborting operation.")
        }

        switch action {
        case .install: installQuickLook()
        case .enable: enableCopy()
        }
    }

    private func installQuickLook() {

        let quickLookURLString = "https://github.com/chockenberry/Provisioning/releases/download/1.0.4/Provisioning-1.0.4.zip"

        if let tempDirectory = FileOps.defaultOps.createTempDirectory() {

            // download zip to temp directory.
            FileOps.defaultOps.downloadFile(quickLookURLString, to: tempDirectory)
            // unzip file

            // create ~/Library/QuickLook if doesn't exist
            //    FileOps.defaultOps.ensureDirectory(FileOps.defaultOps.expandLocalLibraryPath("QuickLook"))
            // copy quicklook plugin to directory
            // restart qlmanage
        }
    }

    private func enableCopy() {
        /*
         If you'd like to be able to copy text out of the Quick Look preview, use these commands to set a hidden Finder preference:

         $ defaults write com.apple.finder QLEnableTextSelection -bool TRUE
         $ killall Finder
         */
    }
}
