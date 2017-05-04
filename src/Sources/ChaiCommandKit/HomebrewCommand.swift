//
//  HomebrewCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 5/3/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// ChaiCommand wrapper around Homebrew
///
/// - install: Installs the passed in formula
/// - update: Updates homebrew with the latest formulas
/// - upgrade: Upgrades the passed in formula
public enum HomebrewCommand: ChaiCommand {

    case install(String)
    case update
    case upgrade(String?)

    static var binary: String? {
        return "brew"
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case let .install(formula):
            return ["install", formula]
        case .update:
            return ["update"]
        case let .upgrade(formula):
            if let formula = formula {
                return ["upgrade", formula]
            }
            return ["upgrade"]
        }
    }
}
