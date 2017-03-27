//
//  FileOperations.swift
//  chaitools
//
//  Created by Travis Fischer on 3/23/17.
//
//

import Foundation

@available(OSX 10.12, *)
class FileOps : NSObject, URLSessionDownloadDelegate {
    
    static let defaultOps = FileOps()
    
    
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
    func removeDirectory(_ dirURL : URL) -> Bool {
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
    
    
    /// Download a file to the given directory.
    ///
    /// - Parameters:
    ///   - file: The URL of the file being downloaded
    ///   - directory: URL of where the file should be downloaded to.
    func downloadFile(_ file: String, to directory: URL) {
        
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: "chaitools-download")
        
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        
        if let url = URL(string: file) {
            print("Downloding file...")
            let downloadTask = session.downloadTask(with:url)
            
            downloadTask.resume()
            
        }

    }
    
    
    /// Delegate method for URLDownloadTask.
    /// Currently will open finder to the location when the download is complete.
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let process = Process(withLaunchPath: "/usr/bin/open", currentDirectoryPath: location.path)
        process.arguments = ["."]
        process.execute()
    }
    
    
    /// Delegate method for URLDownloadTask
    ///
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("Downloaded \(totalBytesWritten/totalBytesExpectedToWrite)")
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
            // handle the error
        }
        return nil
    }

}
