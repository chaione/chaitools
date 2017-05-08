//
//  GemCommand.swift
//  chaitools
//
//  Created by Travis Fischer on 5/8/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// ChaiCommand wrapper around gem
///
/// - install: Installs listed gem package globally
public enum GemCommand: ChaiCommand {

    case install(String)

    static var binary: String? {
        return "gem"
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case let .install(gem):
            return ["install", gem]
        }
    }
}
