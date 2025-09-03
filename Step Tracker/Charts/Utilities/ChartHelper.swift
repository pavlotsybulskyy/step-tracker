//
//  ChartHelper.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 28.08.2025.
//

import Foundation
import Algorithms

/// A utility struct providing helper functions for chart data processing and visualization.
///
/// `ChartHelper` contains static methods for converting health metrics to chart data,
/// parsing selected data, and calculating various statistical measures for charting purposes.
struct ChartHelper {
    
    /// Converts an array of health metrics to chart data format.
    ///
    /// This function maps each health metric to a ``DateValueChartData`` object,
    /// extracting the date and converting the value to a Double for chart visualization.
    ///
    /// - Parameter data: An array of ``HealthMetric`` objects containing health data.
    /// - Returns: An array of ``DateValueChartData`` objects ready for chart rendering.
    ///
    /// ## Example
    /// ```swift
    /// let healthData = [HealthMetric(date: Date(), value: 8000)]
    /// let chartData = ChartHelper.convert(data: healthData)
    /// // Result: [DateValueChartData(date: Date(), value: 8000.0)]
    /// ```
    static func convert(data: [HealthMetric]) -> [DateValueChartData] {
        return data.map {
            DateValueChartData(date: $0.date, value: Double($0.value))
        }
    }
    
    /// Parses and retrieves chart data for a specific selected date.
    ///
    /// This function searches through the provided chart data to find an entry
    /// that matches the selected date. The comparison is done using calendar day matching,
    /// ignoring time components.
    ///
    /// - Parameters:
    ///   - data: An array of ``DateValueChartData`` objects to search through.
    ///   - selectedDate: The target date to find in the data. If `nil`, returns `nil`.
    /// - Returns: A ``DateValueChartData`` object matching the selected date, or `nil` if no match is found.
    ///
    /// ## Example
    /// ```swift
    /// let chartData = [DateValueChartData(date: Date(), value: 8000.0)]
    /// let selected = Date()
    /// let result = ChartHelper.parseSelectedData(from: chartData, in: selected)
    /// // Result: DateValueChartData(date: Date(), value: 8000.0) if dates match
    /// ```
    static func parseSelectedData(
        from data: [DateValueChartData],
        in selectedDate: Date?
    ) -> DateValueChartData? {
        guard let selectedDate else { return nil }
        return data.first {
            Calendar.current.isDate(selectedDate, inSameDayAs: $0.date)
        }
    }
    
    /// Calculates the average value for each weekday across multiple weeks.
    ///
    /// This function groups health metrics by weekday and calculates the average value
    /// for each day of the week. This is useful for showing weekly patterns in health data.
    ///
    /// - Parameter metric: An array of ``HealthMetric`` objects to analyze.
    /// - Returns: An array of ``DateValueChartData`` objects, one for each weekday, containing the average values.
    ///
    /// ## Example
    /// ```swift
    /// let weeklyData = [/* health metrics for multiple weeks */]
    /// let weekdayAverages = ChartHelper.averageWeekdayCount(for: weeklyData)
    /// // Result: 7 DateValueChartData objects, one for each day of the week
    /// ```
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
    
    /// Calculates the average daily weight difference for each weekday across multiple weeks.
    ///
    /// This function computes the daily weight differences between consecutive measurements,
    /// then groups these differences by weekday and calculates the average for each day of the week.
    /// This is useful for identifying weekly patterns in weight changes.
    ///
    /// - Parameter weights: An array of ``HealthMetric`` objects representing weight measurements.
    /// - Returns: An array of ``DateValueChartData`` objects, one for each weekday, containing the average weight differences.
    ///
    /// ## Example
    /// ```swift
    /// let weightData = [/* weight measurements over time */]
    /// let weekdayWeightDiffs = ChartHelper.averageDailyWeightDifference(for: weightData)
    /// // Result: 7 DateValueChartData objects showing average weight changes for each weekday
    /// ```
    ///
    /// ## Note
    /// This function requires at least 2 weight measurements to calculate differences.
    /// If fewer than 2 measurements are provided, an empty array is returned.
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
