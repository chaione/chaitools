//
//  BundleCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/3/17.
//
//

import Foundation

@available(OSX 10.12, *)
/// Applescript ChaiCommands
public enum BundleCommand: ChaiCommand {

    /// run this instead of `install` to make 
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
        case .exec(let arguments):
            return ["exec"] + arguments
        }
    }
}
