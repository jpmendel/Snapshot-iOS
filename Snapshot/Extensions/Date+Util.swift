//
//  Date+Util.swift
//  Snapshot
//
//  Created by Jacob on 10/12/17.
//  Copyright © 2017 Jacob Mendelowitz. All rights reserved.
//

import Foundation

/**
 * Utility extensions for date objects.
 */
extension Date {
    
    // Gets the number of minutes from another date.
    internal func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    
    // Gets the number of hours from another date.
    internal func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    
    // Gets the number of days from another date.
    internal func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    
    // Gets the number of months from another date.
    internal func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    
    // Gets the number of years from another date.
    internal func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
}
