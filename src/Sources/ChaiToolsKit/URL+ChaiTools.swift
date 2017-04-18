//
//  URL+ChaiTools.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/7/16.
//
//

import Foundation

extension URL {
    func isEmpty() -> Bool {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: self.path) else { return true }

        return contents.isEmpty
    }

    func exists() -> Bool {
        return !self.isEmpty()
    }

    func isGitRepo() -> Bool {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: self.path) else { return false }

        return contents.contains(".git")
    }
}
