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

    func subDirectories(_ childDirectories: String...) -> URL {
        return childDirectories.reduce(self) { $0.appendingPathComponent($1, isDirectory: true) }
    }

    func file(_ filePath: String...) -> URL {
        return filePath.reduce(self) { $0.appendingPathComponent($1, isDirectory: false) }
    }

    func contents(options: FileManager.DirectoryEnumerationOptions = .skipsHiddenFiles) throws -> [URL] {
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            return contents
        } catch let e {
            throw e
        }
    }

    func firstItem(withFileExtension fileExtension: String? = nil) -> URL? {
        do {
            guard let fileExtension = fileExtension else {
                return try self.contents().first
            }
            return try contents().filter({$0.path.contains(fileExtension)}).first
        } catch {
            return nil
        }
    }
}
