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
    var verbosity: Verbosity { get set }
    func state(_ message: String, level: Verbosity)
    func instruct(_ message: String, level: Verbosity)
    func error(_ message: String, level: Verbosity)
    func exclaim(_ message: String, level: Verbosity)
    func addVerbosityOptions(options: OptionRegistry)
}

protocol LoggerInputProtocol {
    func awaitInput(message: String?, secure: Bool) -> String
    func awaitInputWithValidation(message: String?, secure: Bool, validation: (_ input: String) -> Bool) -> String
    func awaitInputWithConversion<T>(message: String?, secure: Bool, conversion: (_ input: String) -> T?) -> T
    func awaitInt(message: String?) -> Int
    func awaitYesNoInput(message: String) -> Bool
}

extension LoggerProtocol {
    func error(_ message: String, level: Verbosity = .normal) {
        error(message, level: level)
    }
    func exclaim(_ message: String, level: Verbosity = .normal) {
        exclaim(message, level: level)
    }
    func instruct(_ message: String, level: Verbosity = .normal) {
        instruct(message, level: level)
    }
    func state(_ message: String, level: Verbosity = .normal) {
        state(message, level: level)
    }
}

// Default Input behavior
extension LoggerInputProtocol {

    mutating func addVerbosityOptions(options: OptionRegistry) {
        options.add(flags: ["-v", "--verbose"], usage: "chaitools is more verbose while it executes") {
//            self.verbosity = .verbose
        }

        options.add(flags: ["-d", "--debug"], usage: "chaitools displays debugging statements while executing") {
//            self.verbosity = .debug
        }

        options.add(flags: ["-s", "--silent"], usage: "chaitools runs with minimum statements printed") {
//            self.verbosity = .silent
        }
    }

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

struct LoggerInput: LoggerInputProtocol {}

class Logger: LoggerProtocol {
    func addVerbosityOptions(options: OptionRegistry) {
        options.add(flags: ["-v", "--verbose"], usage: "chaitools is more verbose while it executes") {
            self.verbosity = .verbose
        }

        options.add(flags: ["-d", "--debug"], usage: "chaitools displays debugging statements while executing") {
            self.verbosity = .debug
        }

        options.add(flags: ["-s", "--silent"], usage: "chaitools runs with minimum statements printed") {
            self.verbosity = .silent
        }
    }

    /// The current verbosity level for the system. Defaults to normal.
    var verbosity = Verbosity.normal

    /// Base message statement. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    func state(_ message: String, level: Verbosity = .normal) {
        if verbosity.rawValue >= level.rawValue {
            print(message)
        }
    }

    /// Use when providing instructions to the user. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    func instruct(_ message: String, level: Verbosity = .normal) {
        state("💁  \(message)", level: level)
    }

    /// Displays an error to the user. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    func error(_ message: String, level: Verbosity = .normal) {
        state("❗️ \(message)", level: level)
    }

    /// Exclaims something to the user. Use for success notifications.
    /// Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    func exclaim(_ message: String, level: Verbosity = .normal) {
        state("\(message) 🎉", level: level)
    }
}
