//
//  DownloaderTests.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/12/17.
//
//

import XCTest
@testable import ChaiCommandKit

struct TestChaiURL: ChaiURLProtocol {
    var url: String
}

@available(OSX 10.12, *)
class DownloaderTests: XCTestCase {

    func testUnZip() {
        let testUnZip = UnZip(file: "test.zip")
        XCTAssertEqual(testUnZip.file, "test.zip", "failed to properly set `file`")
    }

    func testTmpUnZip() {
        let tmpZip = UnZip.unzipTemp
        XCTAssertEqual(tmpZip.file, "tmp.zip", "failed to properly set `file`")

    }

    func testDownloader() {
        let testURL = TestChaiURL(url: "downloader/url")
        let download = Downloader(url: testURL)
        XCTAssertEqual(download.url.url, "downloader/url", "failed to properly set `url`")
    }

    func testDownloaderStaticDownload() {
        let testURL = TestChaiURL(url: "static/downloader/url")
        let staticDownload = Downloader.download(url: testURL)
        XCTAssertEqual(staticDownload.url.url, "static/downloader/url", "failed to properly set `url`")
    }
}
