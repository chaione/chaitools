//
//  ShellCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 5/1/17.
//
//

import Foundation
@available(OSX 10.12, *)

/// Shell ChaiCommands
///
/// - move: Move file to a new path
/// - remove: Remove file
/// - open: Open file
/// - copyFile: Copy files into destination
/// - copyDirectory: Copy directory into destination
public enum ShellCommand: ChaiCommand {


    case move(file: String, toPath: String)
    case remove(file: String)
    case open(fileName: String)
    case copyFile(file: String, to: String)
    case copyDirectory(directory: String, to: String)
    
    static var binary: String? {
        return nil
    }

    func arguments() -> ChaiCommandArguments {
        switch self {
        case (let .move(file, toPath)):
            return ["mv", file, toPath]
        case .remove(let file):
            return ["rm", "-rf", file]
        case .open(let file):
            return ["open", file]
        case .copyFile(let file, let directory):
            return ["cp", file, directory]
        case .copyDirectory(let directory1, let directory2):
            let finalDirectory = directory2 != "." ? directory2 : "./\(directory1)"
            return ["cp", "-rf", directory1, finalDirectory]
        }
    }
}
