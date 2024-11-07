//
//  Configuration.swift
//  CommandInterface
//
//  Created by Vaida on 11/8/24.
//

extension CommandInputReader {
    
    public struct Configuration {
        
        internal let stopSequence: [Regex<Substring>]
        
        static let `default` = Configuration(stopSequence: [])
        
    }

    
}
