//
//  AndroidBootstrap.swift
//  chaitools
//
//  Created by Travis Fischer on 3/29/17.
//
//

import Foundation

struct AndroidBootstrap: BootstrapConfig {
 
    func bootstrap(_ projectDirURL : URL) -> Bool {
        
        print("Androids don't need boots")
        return true
    }
}
