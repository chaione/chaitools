//
//  FileOperations.swift
//  chaitools
//
//  Created by Travis Fischer on 3/23/17.
//
//

import Foundation

enum FileOpsFailStatus: ChaiFailStatus {
    case directoryMissing
    case directoryAlreadyExists
    case unknown
}

@available(OSX 10.12, *)
public class FileOps: NSObject {

    public static let defaultOps = FileOps()

    var outputDirectoryString: String!

    private override init() {
        super.init()

        let infoPlist = Bundle(for: type(of: self)).infoDictionary
        // read `OutputDirectory` from plist/xcconfig file
        if let debugDirectory = infoPlist?["OutputDirectory"] as? String {
            outputDirectoryString = debugDirectory
        } else {
            outputDirectoryString = FileManager.default.currentDirectoryPath
        }
    }

    /// Depending if the environment is set to DEBUG, method will return the appropriate `URL` object
    ///
    /// - Returns: `URL` object.
    func outputURLDirectory() -> URL {
        return URL(fileURLWithPath: outputDirectoryString)
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

        guard !doesDirectoryExist(dirURL) else {
            return true
        }

        do {
            MessageTools.state("The local directory does not exist. Attempting to create it...", level: .verbose)
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
            MessageTools.exclaim("Successfully created the directory.", level: .verbose)
            return true
        } catch {

            MessageTools.error("Error creating the directory. \(error)", level: .verbose)
            return false
        }
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
    func removeDirectory(_ dirURL: URL) throws {
        var isDirectory: ObjCBool = ObjCBool(true)

        guard FileManager.default.fileExists(atPath: dirURL.path, isDirectory: &isDirectory) else {
            MessageTools.state("The directory does not exist, so it cannot be removed. 🤔", level: .verbose)
            throw FileOpsFailStatus.directoryMissing
        }
        do {
            try FileManager.default.removeItem(atPath: dirURL.path)
            MessageTools.exclaim("Successfully removed the directory.", level: .verbose)
        } catch {
            MessageTools.error("Error removing the directory. \(error)", level: .verbose)
            throw FileOpsFailStatus.unknown
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
            MessageTools.error("Failed to create temporary directory.", level: .verbose)
        }
        return nil
    }

    /// Convenience method to create a subdirectory of a given directory
    ///
    /// - Parameters:
    ///   - name: The name of the subdirectory to create
    ///   - parent: The parent directory. Defaults to the current directory.
    func createSubDirectory(_ name: String, parent: URL = FileOps.defaultOps.outputURLDirectory()) {
        // create substructure for project
        do {
            try FileManager.default.createDirectory(at: parent.appendingPathComponent(name, isDirectory: true), withIntermediateDirectories: true)
            MessageTools.exclaim("Successfully created \(name) subdirectory.", level: .verbose)
        } catch {
            MessageTools.error("Failed to create \(name) subdirectory.", level: .verbose)
        }
    }
}
