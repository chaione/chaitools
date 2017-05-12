//
//  CurlCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/2/17.
//
//

import Foundation

@available(OSX 10.12, *)
public enum CurlCommand: ChaiCommand {
    case downloadZip(url: ChaiURLProtocol)
    case get(url: ChaiURLProtocol)
    case post(url: ChaiURLProtocol)

    public static var binary: String? {
        return "curl"
    }

    public func arguments() -> ChaiCommandArguments {
        switch self {
        case let .downloadZip(chaiURL):
            return ["-o", "tmp.zip", "-L", chaiURL.url]
        case let .get(chaiURL):
            return ["-X", "GET", chaiURL.url]
        case let .post(chaiURL):
            return ["-X", "POST", chaiURL.url]
        }
    }
}
