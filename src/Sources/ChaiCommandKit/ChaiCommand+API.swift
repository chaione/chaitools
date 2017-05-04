//
//  ChaiCommand+API.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/2/17.
//
//

import Foundation
import ChaiCommandKit

enum ChaiOneCreds: String {
    // TODO: Kyle needs to provide a ChaiBot token
    case circleCiToken = "84312488cf41b03d6b14d30e7e87f2c62c2b8c25"
}

public struct ChaiURL: ChaiURLProtocol {
    public var url: String!

    public static var swiftFormat: ChaiURL {
        return ChaiURL(url: "https://github.com/nicklockwood/SwiftFormat/archive/0.28.4.zip")
    }

    public static func followCircleCi(project: String) -> ChaiURL {
        let url = "https://circleci.com/api/v1.1/project/bitbucket/chaione/\(project)/follow?circle-token=\(ChaiOneCreds.circleCiToken.rawValue)"
        return ChaiURL(url: url)
    }
}
