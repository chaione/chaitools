//
//  RbenvCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 5/3/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// ChaiCommand wrapper around rbenv
///
/// - install: Installs the given version of ruby
/// - global: Sets given version of ruby as the global default
/// - local: Sets given version of ruby as the local default
public enum RbenvCommand: ChaiCommand {

    case install(String)
    case global(String)
    case local(String)
    case version
    case rbinit
    case versions

    static var binary: String? {
        return "rbenv"
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case let .install(version):
            return ["install", version]
        case let .global(version):
            return ["global", version]
        case let .local(version):
            return ["local", version]
        case .rbinit:
            return ["init"]
        case .version:
            return ["version"]
        case .versions:
            return ["versions"]
        }
    }

    /// Checks if a particular version of ruby is installed
    ///
    /// - Parameter version: The version of ruby to look for
    /// - Returns: True if that version is installed
    /// - Throws: ChaiError if command fails to run
    public static func isInstalled(version: String) -> Bool {
        var installed = false
        do {
            try versions.run { output in
                installed = output.contains(version)
            }
            return installed
        } catch {
            return false
        }
    }
}
