//
//  MessageTools.swift
//  chaitools
//
//  Created by Travis Fischer on 3/31/17.
//
//

import Foundation
import SwiftCLI

enum Verbosity: Int {
    case silent = 0
    case normal
    case verbose
    case debug
}

enum LoggerColor: String {
    static var includeColor = true

    case none = "\u{001B}[0;39m"
    case red = "\u{001B}[0;31m"
    case green = "\u{001B}[0;32m"
    case yellow = "\u{001B}[0;33m"
    case blue = "\u{001B}[0;34m"
    case cyan = "\u{001B}[0;36m"

    func coloredMessage(_ message: String) -> String {
        guard LoggerColor.includeColor else {
            return message
        }

        let endColor = "\u{001B}[0;0m"
        return rawValue + message + endColor
    }
}

struct MessageTools {

    static func addVerbosityOptions(options: OptionRegistry) {
        options.add(flags: ["--no-color"], usage: "All logs will be published with no colors.") {
            LoggerColor.includeColor = false
        }

        options.add(flags: ["-v", "--verbose"], usage: "chaitools is more verbose while it executes") {
            MessageTools.verbosity = .verbose
        }

        options.add(flags: ["-d", "--debug"], usage: "chaitools displays debugging statements while executing") {
            MessageTools.verbosity = .debug
        }

        options.add(flags: ["-s", "--silent"], usage: "chaitools runs with minimum statements printed") {
            MessageTools.verbosity = .silent
        }
    }

    /// The current verbosity level for the system. Defaults to normal.
    static var verbosity = Verbosity.normal

    /// Base message statement. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func state(_ message: String, color: LoggerColor? = nil, level: Verbosity = .normal) {
        if verbosity.rawValue >= level.rawValue {
            let message = color?.coloredMessage(message) ?? message
            print("\(message)")
        }
    }

    static func awaitYesNoInput(question: String, color: LoggerColor = .yellow) -> Bool {
        return Input.awaitYesNoInput(message: color.coloredMessage(question))
    }

    static func awaitInput(question: String, color: LoggerColor = .yellow) -> String {
        return Input.awaitInput(message: color.coloredMessage(question))
    }

    /// Use when providing instructions to the user. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func instruct(_ message: String, color: LoggerColor = .none, level: Verbosity = .normal) {
        state(color.coloredMessage("💁  \(message)"), level: level)
    }

    /// Displays an error to the user. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func error(_ message: String, color: LoggerColor = .red, level: Verbosity = .normal) {
        state(color.coloredMessage("❗️ error: \(message)"), level: level)
    }

    /// Exclaims something to the user. Use for success notifications.
    /// Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func exclaim(_ message: String, color: LoggerColor = .green, level: Verbosity = .normal) {
        state(color.coloredMessage("\(message) 🎉"), level: level)
    }
}
