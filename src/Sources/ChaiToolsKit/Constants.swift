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

enum FileOpsError: Error {
    case directoryMissing
    case directoryAlreadyExists
    case unknown
}

enum GitRepoError: Error {
    case alreadyInitialized
    case missingRemoteURL
    case missingLocalRepo
    case nonEmptyRepo
    case commandFaliure(message: String)
    case unknown
}

enum BootstrapCommandError: Error {
    case unrecognizedTechStack
    case projectAlreadyExistAtLocation
    case generic(message: String)
    case unknown
}
