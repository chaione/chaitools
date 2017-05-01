//
//  AppleScript.swift
//  ChaiCommandKit
//
//  Created by Fabian Buentello on 04/28/17.
//  Copyright © 2016 ChaiOne. All rights reserved.
//

import Foundation

@available(OSX 10.12, *)
/// Applescript ChaiCommands
public enum AppleScript: ChaiCommandProtocol {

    case openXcode
    case quitXcode

    public static var binary: String? {
        return "osascript"
    }

    public func arguments() -> ChaiCommandArguments {
        switch self {
        case .openXcode:
            return ["-e", "tell application \"Xcode\" to activate", "-e", "tell application \"System Events\" to keystroke \"n\" using {command down, shift down}"]

        case .quitXcode:
            return ["-e", "tell application \"Xcode\" to quit"]
        }
    }
}
