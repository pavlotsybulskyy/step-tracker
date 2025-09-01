//
//  Array+Ext.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 02.09.2025.
//

import Foundation

extension Array where Element == Double {
    var average: Double {
        guard !isEmpty else {
            return 0
        }
        let total = self.reduce(0, +)
        return  total / Double(count)
    }
}
