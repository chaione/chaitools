//
//  NPMCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 5/3/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// ChaiCommand wrapper around npm
///
/// - install: Installs listed npm package
/// - uninstall: Uninstalls listed npm package
public enum NPMCommand: ChaiCommand {

    case install(String)
    case uninstall(String)
    case update(String?)

    static var binary: String? {
        return "npm"
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case let .install(package):
            return ["install", "-g", package]
        case let .uninstall(package):
            return ["uninstall", package]
        case let .update(package):
            if let package = package {
                return ["update", "-g", package]
            }
            return ["update", "-g"]
        }
    }
}
