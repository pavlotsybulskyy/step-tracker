//
//  ChartMath.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 22.08.2025.
//

import Foundation
import Algorithms

struct ChartMath {
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [WeekdayChartData] {
        let sortedByWeekday = metric.sorted { $0.date.weekday < $1.date.weekday }
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekday == $1.date.weekday }
        
        var weekdayChartData: [WeekdayChartData] = []
        for array in weekdayArray {
            guard let first = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total / Double(array.count)
            
            weekdayChartData.append(WeekdayChartData(date: first.date, value: avgSteps))
        }
        
        return weekdayChartData
    }
}
