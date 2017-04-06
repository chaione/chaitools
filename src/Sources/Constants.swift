//
//  Constants.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/6/17.
//
//

import Foundation

// Maybe make this an struct...
enum GitRepoFailStatus: Equatable {
    case alreadyInitialized
    case missingRemoteURL
    case missingLocalRepo
    case nonEmptyRepo
    case unknown
}

enum GitRepoStatus {
    case success
    case failure(GitRepoFailStatus)

    static func testBool(status: Bool) -> GitRepoStatus {
        if status {
            return success
        }
        // Here we'll test across different types of status
        // and return the appropriate Fail Status
        return .failure(.unknown)
    }

    func isSuccessful() -> Bool {
        return self == .success
    }
}

func == (lhs: GitRepoStatus, rhs: GitRepoStatus) -> Bool {
    switch (lhs, rhs) {
    case let (.failure(error1), .failure(error2)):
        return error1 == error2

    case (.success, .success):
        return true

    default:
        return false
    }
}
