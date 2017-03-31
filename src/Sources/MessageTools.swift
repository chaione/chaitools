//
//  MessageTools.swift
//  chaitools
//
//  Created by Travis Fischer on 3/31/17.
//
//

import Foundation

enum Verbosity : Int {
    case silent = 0
    case normal
    case verbose
    case debug
}

struct MessageTools {
    
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
    static func instruct(_ message :String, level: Verbosity = .normal) {
        state("💁  \(message)", level: level)
    }
    
    /// Displays an error to the user. Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func error(_ message : String, level: Verbosity = .normal) {
        state("❗️ \(message)", level:level)
    }
    
    /// Exclaims something to the user. Use for success notifications. 
    /// Prints a message at a given verbosity.
    ///
    /// - Parameters:
    ///  - message: The message to be displayed to the user
    ///  - level: The verbosity level required to print the message. Defaults to normal.
    static func exclaim(_ message: String, level: Verbosity = .normal) {
        state("\(message) 🎉",level:level)
    }
}
