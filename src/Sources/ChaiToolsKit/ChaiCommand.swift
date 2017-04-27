//
//  ChaiCommand.swift
//  chaitools
//
//  Created by Fabian Buentello on 4/26/17.
//
//

import Foundation

@available(OSX 10.12, *)
protocol CommandProtocol {
    var launchPath: String { get }
}

@available(OSX 10.12, *)
extension CommandProtocol where Self: RawRepresentable {

    func generateCommand(withArguments arguments: [String]) -> ChaiCommand {
        return ChaiCommand(
            launchPath: launchPath,
            arguments: arguments,
            preMessage: "Starting command: `\(self.rawValue)`",
            successMessage: "Successfully \(self.rawValue).",
            failureMessage: "Failed to \(self.rawValue)."
        )
    }
}
