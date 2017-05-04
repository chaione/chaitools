//
//  URL+ChaiTools.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/7/16.
//
//

import Foundation
import ChaiCommandKit

extension URL {
    func isEmpty() -> Bool {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: self.path) else { return true }

        return contents.isEmpty
    }

    func exists() -> Bool {
        return !isEmpty()
    }

    func isGitRepo() -> Bool {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: self.path) else { return false }

        return contents.contains(".git")
    }

    @discardableResult func createIfMissing() throws -> URL {
        var isDirectory: ObjCBool = ObjCBool(true)

        guard !FileManager.default.fileExists(atPath: self.path, isDirectory: &isDirectory) else {
            return self
        }

        do {
            try FileManager.default.createDirectory(at: self, withIntermediateDirectories: true)
            return self
        } catch {
            throw ChaiError.generic(message: "Failed to create: \(self.path)")
        }
    }

    func subDirectories(_ childDirectories: String...) -> URL {
        return childDirectories.reduce(self) { $0.appendingPathComponent($1, isDirectory: true) }
    }

    func file(_ filePath: String...) -> URL {
        return filePath.reduce(self) { $0.appendingPathComponent($1, isDirectory: false) }
    }

    func contents(options _: FileManager.DirectoryEnumerationOptions = .skipsHiddenFiles) throws -> [URL] {
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
                return try contents().first
            }
            return try contents().filter({ $0.path.contains(fileExtension) }).first
        } catch {
            return nil
        }
    }
}
