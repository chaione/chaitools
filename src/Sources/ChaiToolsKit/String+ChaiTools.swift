//
//  String+ChaiTools.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/7/16.
//
//

import Foundation

extension String {
    func isGitRepo() -> Bool {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: self) else { return false }

        return contents.contains(".git")
    }

    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = self as NSString
            let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range) }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
