//
//  Extensions.swift
//  Template
//
//  Created by Vaida on 7/8/24.
//

import FinderItem
import ArgumentParser


extension FinderItem: @retroactive ExpressibleByArgument {
    
    public init?(argument: String) {
        self.init(at: FinderItem.normalize(shellPath: argument))
    }
    
}
