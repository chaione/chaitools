//
//  FastlaneCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/28/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// Fastlane ChaiCommands
///
/// - bootstrap: run `fastlane bootstrap`
/// - bootstrapChaiToolsSetup: run `fastlane bootstrap_chai_tools_setup`
/// - lane: Generic case that will allow you to run any lane that is not specified as a case.
public enum FastlaneCommand: ChaiCommand {

    case bootstrap
    case bootstrapChaiToolsSetup
    case lane(String)
    public static var binary: String? {
        return "bundle"
    }

    public func arguments() -> ChaiCommandArguments {
        switch self {
        case .bootstrap:
            return ["exec", "fastlane", "bootstrap"]
        case .bootstrapChaiToolsSetup:
            return ["exec", "fastlane", "bootstrap_chai_tools_setup"]
        case let .lane(lane):
            return [lane]
        }
    }
}
