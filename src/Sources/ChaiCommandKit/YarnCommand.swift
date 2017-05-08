//
//  YarnCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 5/5/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// ChaiCommand wrapper around yarn
///
/// - install: Installs listed yarn package globally
/// - uninstall: Uninstalls listed npm package
public enum YarnCommand: ChaiCommand {

    case add(String)
    case remove(String)
    case upgrade(String?)

    static var binary: String? {
        return "yarn"
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case let .add(package):
            return ["global", "add", package]
        case let .remove(package):
            return ["global", "remove", package]
        case let .upgrade(package):
            if let package = package {
                return ["global", "upgrade", package]
            }
            return ["global", "upgrade"]
        }
    }
}
