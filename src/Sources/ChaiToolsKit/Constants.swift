//
//  Constants.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/6/17.
//
//

import Foundation

protocol Iteratable {}
extension RawRepresentable where Self: RawRepresentable {

    static func iterateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) {
                $0.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            if next.hashValue != i { return nil }
            i += 1
            return next
        }
    }
}

extension Iteratable where Self: RawRepresentable, Self: Hashable {
    static func hashValues() -> AnyIterator<Self> {
        return iterateEnum(self)
    }

    static func rawValues() -> [Self.RawValue] {
        return hashValues().map({$0.rawValue})
    }
}

protocol BootstrapConfig {

    func bootstrap(_ projectDirURL: URL) throws
    var type: String! {get}
    var projectURL: URL! {get set}
    init(repoUrlString: String!)
}

func == (lhs: BootstrapConfig, rhs: BootstrapConfig) -> Bool {
    return lhs.type == rhs.type
}

// MARK: - Error Enums

extension Error {
    var description: String {
        switch self {
        case (let e as GitRepoError):
            return e.localizedDescription
        case (let e as BootstrapCommandError):
            return e.localizedDescription
        case (let e as FileOpsError):
            return e.localizedDescription
        default:
            return "unknown error to ChaiTools."
        }
    }
}

enum FileOpsError: Error {
    case directoryMissing
    case directoryAlreadyExists
    case unknown

    var localizedDescription: String {
        switch self {
        case .directoryMissing:
            return "Destination directory is Missing."
        case .directoryAlreadyExists:
            return "Destination directory already exists."
        case .unknown:
            return "ChaiTools does not know what happened 😭"
        }
    }
}

enum GitRepoError: Error {
    case alreadyInitialized
    case missingRemoteURL
    case missingLocalRepo
    case nonEmptyRepo
    case commandFaliure(message: String)
    case unknown

    var localizedDescription: String {
        switch self {
        case .alreadyInitialized:
            return "Local git repo is already initialized."
        case .missingRemoteURL:
            return "ChaiTools is missing a remote URL to pull from."
        case .missingLocalRepo:
            return "ChaiTools is missing a Local Repo."
        case .nonEmptyRepo:
            return "Destination directory needs to be empty"
        case .commandFaliure(let message):
            return message
        case .unknown:
            return "ChaiTools does not know what happened 😭"
        }
    }
}

enum BootstrapCommandError: Error {
    case unrecognizedTechStack
    case projectAlreadyExistAtLocation(projectName: String)
    case generic(message: String)
    case unknown

    var localizedDescription: String {
        switch self {
        case .unrecognizedTechStack:
            return "ChaiTools did not recognize Tech Stack"
        case .projectAlreadyExistAtLocation(let projectName):
            return "Project \(projectName) already exists at this location."
        case .generic(let message):
            return message
        case .unknown:
            return "ChaiTools does not know what happened 😭"
        }
    }
}
