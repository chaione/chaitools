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
public enum Fastlane : ChaiCommandProtocol {

    case bootstrap
    case bootstrapChaiToolsSetup
    case lane(String)
    static var binary: String? {
        return "fastlane"
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case .bootstrap:
            return ["bootstrap"]
        case .bootstrapChaiToolsSetup:
            return ["bootstrap_chai_tools_setup"]
        case .lane(let lane):
            return [lane]
        }
    }
}
