//
//  HealthMetric.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 20.08.2025.
//

import Foundation

struct HealthMetric: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double
}
