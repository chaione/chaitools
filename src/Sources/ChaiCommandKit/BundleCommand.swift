//
//  BundleCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/3/17.
//
//

import Foundation

@available(OSX 10.12, *)
/// BundleCommand ChaiCommands
public enum BundleCommand: ChaiCommand {

    /// install gems using version from `Gemfile.lock`
    case install
    // sure computers packages are up-to-date
    case update

    // execute bundle commands such as `bundle exec calabash-ios download`
    case exec(arguments: [String])

    public static var binary: String? {
        return "bundle"
    }

    public func arguments() -> ChaiCommandArguments {
        switch self {
        case .update:
            return ["update"]
        case .install:
            return ["install"]
        case let .exec(arguments):
            return ["exec"] + arguments
        }
    }
}
