//
//  Array+Util.swift
//  Snapshot
//
//  Created by Jacob on 10/11/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import Foundation

/**
 * Utility extensions for the array.
 */
extension Array where Element: Equatable {
    
    // Remove an object from an array by value.
    internal mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
    
}
