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

protocol LoggerProtocol {
    func state(_ message: String, level: Verbosity)
    func instruct(_ message: String, level: Verbosity)
    func error(_ message: String, level: Verbosity)
    func exclaim(_ message: String, level: Verbosity)
}

extension LoggerProtocol {
    func error(_ message: String, level: Verbosity = .normal) {
        MessageTools.error(message, level: level)
    }
    func exclaim(_ message: String, level: Verbosity = .normal) {
        MessageTools.exclaim(message, level: level)
    }
    func instruct(_ message: String, level: Verbosity = .normal) {
        MessageTools.instruct(message, level: level)
    }
    func state(_ message: String, level: Verbosity = .normal) {
        MessageTools.state(message, level: level)
    }
}

protocol LoggerInputProtocol {
    func awaitInput(message: String?, secure: Bool) -> String
    func awaitInputWithValidation(message: String?, secure: Bool, validation: (_ input: String) -> Bool) -> String
    func awaitInputWithConversion<T>(message: String?, secure: Bool, conversion: (_ input: String) -> T?) -> T
    func awaitInt(message: String?) -> Int
    func awaitYesNoInput(message: String) -> Bool
}

// Default Input behavior
extension LoggerInputProtocol {
    func awaitInput(message: String?, secure: Bool = false) -> String {
        return Input.awaitInput(message: message, secure: secure)
    }

    func awaitInputWithValidation(message: String?, secure: Bool = false, validation: (_ input: String) -> Bool) -> String {
        return Input.awaitInputWithValidation(message: message, secure: secure, validation: validation)
    }

    func awaitInputWithConversion<T>(message: String?, secure: Bool = false, conversion: (_ input: String) -> T?) -> T {
        return Input.awaitInputWithConversion(message: message, secure: secure, conversion: conversion)
    }

    func awaitInt(message: String?) -> Int {
        return Input.awaitInt(message: message)
    }

    func awaitYesNoInput(message: String = "Confirm?") -> Bool {
        return Input.awaitYesNoInput(message: message)
    }



}

struct Logger: LoggerProtocol {}
struct LoggerInput: LoggerInputProtocol {}

struct MessageTools {

    static func addVerbosityOptions(options: OptionRegistry) {
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
    static func state(_ message: String, level: Verbosity = .normal) {
        if verbosity.rawValue >= level.rawValue {
            print(message)
        }
    }

    /// Use when providing instructions to the user. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func instruct(_ message: String, level: Verbosity = .normal) {
        state("💁  \(message)", level: level)
    }

    /// Displays an error to the user. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func error(_ message: String, level: Verbosity = .normal) {
        state("❗️ \(message)", level: level)
    }

    /// Exclaims something to the user. Use for success notifications.
    /// Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func exclaim(_ message: String, level: Verbosity = .normal) {
        state("\(message) 🎉", level: level)
    }
}
