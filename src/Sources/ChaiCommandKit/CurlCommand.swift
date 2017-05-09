//
//  CurlCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/2/17.
//
//

import Foundation

struct UnZip: ChaiCommand {
    let file: String

    static var binary: String? {
        return "unzip"
    }

    static var unzipTemp: UnZip {
        return UnZip(file: "tmp.zip")
    }

    /// Method will unzip file to `tmp folder`
    ///
    /// - Returns: `ChaiCommandArguments`
    func arguments() -> ChaiCommandArguments {
        return ["-d", "tmp", file]
    }
}

struct Curl: ChaiCommand {

    let url: DownloadURLs
    static var binary: String? {
        return "curl"
    }

    func arguments() -> ChaiCommandArguments {
        return ["-o", "tmp.zip", "-L", url.rawValue]
    }
}

@available(OSX 10.12, *)
public struct CurlCommand {
    let url: DownloadURLs

    public static func download(url: DownloadURLs) -> CurlCommand {
        return CurlCommand(url: url)
    }

    /// Method will download zip file
    ///
    /// - Parameter directory: `URL`
    /// - Returns: `Process`
    /// - Throws: `ChaiError`
    @discardableResult public func run(in directory: URL) throws -> Process {
        try Curl(url: url).run(in: directory)
        try UnZip.unzipTemp.run(in: directory)
        return try ShellCommand.remove(file: "tmp.zip").run(in: directory)
    }
}
