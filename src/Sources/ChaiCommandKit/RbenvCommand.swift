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
            return ["--version"]
        }
    }
} 
