//
//  Downloader.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/4/17.
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

@available(OSX 10.12, *)
public struct Downloader {
    let url: ChaiURLProtocol

    public static func download(url: ChaiURLProtocol) -> Downloader {
        return Downloader(url: url)
    }

    /// Method will download zip file
    ///
    /// - Parameter directory: `URL`
    /// - Returns: `Process`
    /// - Throws: `ChaiError`
    @discardableResult public func run(in directory: URL) throws -> Process {
        try CurlCommand.downloadZip(url: url).run(in: directory)
        try UnZip.unzipTemp.run(in: directory)
        return try ShellCommand.remove(file: "tmp.zip").run(in: directory)
    }
}
