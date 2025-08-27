//
//  ChartDataTypes.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 22.08.2025.
//

import Foundation

struct DateValueChartData: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let value: Double
}
