//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 28.08.2025.
//

import Foundation
import Algorithms

struct ChartHelper {
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        return data.map {
            DateValueChartData(date: $0.date, value: Double($0.value))
        }
    }
    
    static func parseSelectedData(
        from data: [DateValueChartData],
        in selectedDate: Date?
    ) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    static func averageWeekdayCount(for metric: [HealthMetric]) -> [DateValueChartData] {
        let sortedByWeekday = metric.sorted(using: KeyPathComparator(\.date.weekday))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekday == $1.date.weekday }
        
        var weekdayChartData: [DateValueChartData] = []
        for array in weekdayArray {
            guard let first = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgSteps = total / Double(array.count)
            
            weekdayChartData.append(DateValueChartData(date: first.date, value: avgSteps))
        }
        
        return weekdayChartData
    }
    
    static func averageDailyWeightDifference(for weights: [HealthMetric]) -> [DateValueChartData] {
        var diffValues: [(date: Date, value: Double)] = []
        
        guard weights.count > 1 else { return [] }
        for i in 1..<weights.count {
            let date = weights[i].date
            let diff = weights[i].value - weights[i - 1].value
            diffValues.append((date: date, value: diff))
        }
        
        let sortedByWeekday = diffValues.sorted(using: KeyPathComparator(\.date.weekday))
        let weekdayArray = sortedByWeekday.chunked { $0.date.weekday == $1.date.weekday }
        
        var weekdayChartData: [DateValueChartData] = []
        for array in weekdayArray {
            guard let first = array.first else { continue }
            let total = array.reduce(0) { $0 + $1.value }
            let avgWeightDiff = total / Double(array.count)
            
            weekdayChartData.append(DateValueChartData(date: first.date, value: avgWeightDiff))
        }
        
        return weekdayChartData
    }
}
