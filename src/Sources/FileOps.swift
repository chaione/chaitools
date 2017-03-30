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
        var isDirectory: ObjCBool = ObjCBool(true)
        if !FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDirectory) {
            do {
                print("The local directory does not exist. Attempting to create it...")
                try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
                print("Successfully created the directory.")
                return true
            } catch {
                print("❗️ Error creating the directory. \(error)")
                return false
            }
        }

        return true
    }

    /// Generic actions to delete a given directory.
    ///
    /// - Parameter dirURL: URL to the directory to be deleted.
    /// - Returns: True if succeeded, false otherwise.
    func removeDirectory(_ dirURL: URL) -> Bool {
        var isDirectory: ObjCBool = ObjCBool(true)

        if FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDirectory) {
            do {
                try FileManager.default.removeItem(atPath: dirURL.path)
                print("Successfully removed the directory. 🎉")
                return true
            } catch {
                print("❗️ Error removing the directory. \(error)")
                return false
            }
        } else {
            print("The directory does not exist, so it cannot be removed. 🤔")
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
}
