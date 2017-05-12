//
//  ChaiCommand+API.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/2/17.
//
//

import Foundation
import ChaiCommandKit

public struct ChaiURL: ChaiURLProtocol {
    public var url: String!
    // get 'circleiosapplication' out of 'git@bitbucket.org:chaione/circleiosapplication.git'
    public static let repoNameRegex: String = "([^/]+)(?=\\.git)"

    public static var swiftFormat: ChaiURL {
        return ChaiURL(url: "https://github.com/nicklockwood/SwiftFormat/archive/0.28.4.zip")
    }

    public static var provisioningQuickLook: ChaiURL {
        return ChaiURL(url: "https://github.com/chockenberry/Provisioning/releases/download/1.0.4/Provisioning-1.0.4.zip")
    }

    public static func followCircleCi(project: String) -> ChaiURL {
        let url = "https://circleci.com/api/v1.1/project/bitbucket/chaione/\(project)/follow?circle-token=\(Configuration.circleCiToken.value)"
        return ChaiURL(url: url)
    }
}
