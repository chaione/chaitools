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

    func bootstrap(_ projectDirURL: URL) -> Bool
    var type: String! {get}
    var projectURL: URL! {get set}
    init(repoUrlString: String!)
}

func == (lhs: BootstrapConfig, rhs: BootstrapConfig) -> Bool {
    return lhs.type == rhs.type
}

// MARK: - Enum Protocols

protocol ChaiFailStatus: Error, Hashable {}
protocol ChaiStatus: Equatable {
    func isSuccessful() -> Bool
}

enum GitRepoStatus: ChaiStatus {
    case success
    case failure(GitRepoFailStatus)

    internal enum GitRepoFailStatus: ChaiFailStatus {
        case alreadyInitialized
        case missingRemoteURL
        case missingLocalRepo
        case nonEmptyRepo
        case unknown
    }

    func isSuccessful() -> Bool {
        return self == .success
    }
}

enum FileOpsStatus: ChaiStatus {
    case success
    case failure(FileOpsFailStatus)

    internal enum FileOpsFailStatus: ChaiFailStatus {
        case directoryMissing
        case directoryAlreadyExists
        case unknown
    }

    func isSuccessful() -> Bool {
        return self == .success
    }
}

func == <T: ChaiStatus>(lhs: T, rhs: T) -> Bool {

    if lhs is GitRepoStatus {
        switch (lhs as! GitRepoStatus, rhs as! GitRepoStatus) {
        case (.success, .success):
            return true
        case (.failure(let lError), .failure(let rError)):
            return lError == rError
        default: return false
        }
    }

    if lhs is FileOpsStatus {
        switch (lhs as! GitRepoStatus, rhs as! GitRepoStatus) {
        case (.success, .success):
            return true
        case (.failure(let lError), .failure(let rError)):
            return lError == rError
        default: return false
        }
    }

    return false
}

enum BootstrapStatus<T: Equatable> {

    typealias Value = T
    case success(Value)
    case failure(BootstrapCommandFailStatus)

    internal enum BootstrapCommandFailStatus: ChaiFailStatus {
        case unrecognizedTechStack
        case projectAlreadyExistAtLocation
        case unknown
    }
}

func == <T>(lhs: BootstrapStatus<T>, rhs: BootstrapStatus<T>) -> Bool {
    switch(lhs, rhs) {
    case (.success, .success):
        return true
    case (.failure(let lError), .failure(let rError)):
        return lError == rError
    default: return false
    }
}
