//
//  ProvisioningCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 12/6/16.
//
//

import Foundation
import SwiftCLI

enum ProvisioningActions : String {
    case install
    case enable
}

@available(OSX 10.12, *)
class ProvisioningCommand: Command {

    var name: String = "provisioning"
    var signature: String = "<action>"
    var shortDescription: String = "Install Provisioning Quick Look plugin or enable copying from the plugin"
    
    func execute(arguments: CommandArguments) throws {
        
        guard let action = ProvisioningActions(rawValue:arguments.requiredArgument("action")) else {
            return print("❗️ \"\(arguments.requiredArgument("action"))\" is not a valid option. Aborting operation.")
        }
        
        switch action {
        case .install: installQuickLook()
        case .enable: enableCopy()
        }
        
    }
    
    private func installQuickLook() {
        
        // download zip to temp directory.
        // unzip file
        // create ~/Library/QuickLook if doesn't exist
        // copy quicklook plugin to directory
        // restart qlmanage
        
    }
    
    private func enableCopy() {
        /*
         If you'd like to be able to copy text out of the Quick Look preview, use these commands to set a hidden Finder preference:
         
         $ defaults write com.apple.finder QLEnableTextSelection -bool TRUE
         $ killall Finder
         */
    }
}
