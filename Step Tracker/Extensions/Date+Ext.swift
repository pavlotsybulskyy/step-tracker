//
//  Date+Ext.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 22.08.2025.
//

import Foundation

extension Date {
    var weekday: Int {
        Calendar.current.component(.weekday, from: self)
    }
}
