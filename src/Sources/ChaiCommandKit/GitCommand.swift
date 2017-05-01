//
//  GitCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/28/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// Git commands that would typically be ran from the terminal
public enum GitCommand: ChaiCommand, Equatable {

    case clone(url: String)
    case pull
    case ginit
    case add
    case commit
    case remote(remoteOption)
    case push

    static var binary: String? {
        return "git"
    }
    public enum remoteOption {
        case add(String)
        case remove(String)

        func arguments() -> [String] {
            switch self {
            case .add(let urlPath):
                return ["remote", "add", urlPath, "."]
            case .remove(let urlPath):
                return ["remote", "remove", urlPath]
            }
        }

        public static func ==(lhs: remoteOption, rhs: remoteOption) -> Bool {
            switch (lhs, rhs) {
            case (let .add(option1), let .add(option2)),
                 (let .remove(option1), let .remove(option2)):
                return option1 == option2

            default:
                return false
            }
        }
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case .clone(let urlPath):
            return ["clone", urlPath, "."]
        case .pull:
            return ["pull"]
        case .ginit:
            return ["init"]
        case .add:
            return ["add", "."]
        case .commit:
            return ["commit", "-m \"Initial commit by chaitools\""]
        case .remote(let option):
            return option.arguments()
        case .push:
            return ["push", "-u", "origin", "master"]
        }
    }
}

@available(OSX 10.12, *)
public func ==(lhs: GitCommand, rhs: GitCommand) -> Bool {
    switch (lhs, rhs) {
    case (let .clone(url1), let .clone(url2)):
        return url1 == url2
    case ( .remote, .remote):
        return lhs == rhs
    case (.ginit, .ginit),
         (.add, .add),
         (.commit, .commit),
         (.pull, .pull):
        return true

    default:
        return false
    }
}
