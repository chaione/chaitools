//
//  String+ChaiTools.swift
//  chaitools
//
//  Created by Alex Du Bois on 11/7/16.
//
//

import Foundation

extension String {
    func isGitRepo() -> Bool {
        guard let contents = try? FileManager.default.contentsOfDirectory(atPath: self) else { return false }

        return contents.contains(".git")
    }
}
