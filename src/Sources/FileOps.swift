//
//  FileOperations.swift
//  chaitools
//
//  Created by Travis Fischer on 3/23/17.
//
//

import Foundation

@available(OSX 10.12, *)
class FileOps: NSObject {

    static let defaultOps = FileOps()
    
    private override init() {
        super.init()
    }

    /// Takes a subpath and returns a full path going to the user's Library directory.
    ///
    /// - Parameter directory: A library subpath
    /// - Returns: The fully qualified path into the user's library to the given directory.
    func expandLocalLibraryPath(_ directory: String) -> URL {
        return FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent("Library", isDirectory: true).appendingPathComponent(directory, isDirectory: true)
    }

    /// Checks if a directory exists and creates it if it does not.
    ///
    /// - Parameter dirURL: The local URL of the directory to be created
    /// - Returns: True if succeeds and false otherwise.
    func ensureDirectory(_ dirURL: URL) -> Bool {
        if !doesDirectoryExist(dirURL) {
            do {
                print("The local directory does not exist. Attempting to create it...")
                try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
                print("Successfully created the directory. 🎉")
                return true
            } catch {
                print("❗️ Error creating the directory. \(error)")
                return false
            }
        }
        return true
    }

    /// Convenience method to check if a directory exists
    ///
    /// - Returns: True if the directory exists, false otherwise.
    func doesDirectoryExist(_ url: URL) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(true)
        return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory)
    }

    /// Generic actions to delete a given directory.
    ///
    /// - Parameter dirURL: URL to the directory to be deleted.
    /// - Returns: True if succeeded, false otherwise.
    func removeDirectory(_ dirURL: URL) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(true)

        guard FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDirectory) else {
            print("The directory does not exist, so it cannot be removed. 🤔")
            return false
        }
        do {
            try FileManager.default.removeItem(atPath: dirURL.path)
            print("Successfully removed the directory. 🎉")
            return true
        } catch {
            print("❗️ Error removing the directory. \(error)")
            return false
        }
    }

    /// Creates a new temporary directory
    ///
    /// - Returns: A directory on the user's temporary path.
    func createTempDirectory() -> URL? {
        do {
            let temporaryDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory,
                                                                    in: .userDomainMask,
                                                                    appropriateFor: FileManager.default.homeDirectoryForCurrentUser,
                                                                    create: true)
            return temporaryDirectoryURL
        } catch {
            print("❗️ Failed to create temporary directory.")
        }
        return nil
    }

    /// Convenience method to create a subdirectory of a given directory
    ///
    /// - Parameters:
    ///   - name: The name of the subdirectory to create
    ///   - parent: The parent directory. Defaults to the current directory.
    func createSubDirectory(_ name: String, parent: URL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)) {
        // create substructure for project
        do {
            try FileManager.default.createDirectory(at: parent.appendingPathComponent(name, isDirectory: true), withIntermediateDirectories: true)
            print("Successfully created \(name) subdirectory. 🎉")
        } catch {
            print("❗️ Failed to create \(name) subdirectory.")
        }
    }
}
