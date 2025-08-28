//
//  WeightDiffBarChart.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 24.08.2025.
//

import SwiftUI
import Charts

struct WeightDiffBarChart: View {
    
    @State private var selectedDate: Date?
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedData: DateValueChartData? {
        ChartHelper.parseSelectedData(from: chartData, in: selectedDate)
    }
    
    var body: some View {
        ChartContainer(
            title: "Average Weight Change",
            symbol: "figure",
            subtitle: "Per Weekday (Last 28 days)",
            context: .weight,
            isNav: false
        ) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.bar",
                    title: "No Data",
                    description: "There is no weight data from Health App"
                )
            } else {
                Chart {
                    if let selectedData{
                        RuleMark(x: .value("Selected metric", selectedData.date, unit: .day))
                            .foregroundStyle(Color.secondary.opacity(0.3))
                            .offset(y: -10)
                            .annotation(
                                position: .top,
                                spacing: 0,
                                overflowResolution: .init(x:.fit(to: .chart), y: .disabled),
                                content: {
                                    AnnotationView(
                                        data: selectedData,
                                        context: .weight
                                    )
                                }
                            )
                    }
                    ForEach(chartData) { weightDiff in
                        BarMark(
                            x: .value("Date", weightDiff.date, unit:. day),
                            y: .value("Weight Diff", weightDiff.value)
                        )
                        .foregroundStyle(weightDiff.value >= 0 ? Color.indigo.gradient : Color.mint.gradient)
                    }
                }
                .frame(height: 150)
                .chartXSelection(value: $selectedDate.animation(.easeInOut))
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day)) {
                        AxisValueLabel(format: .dateTime.weekday(), centered: true)
                    }
                }
                .chartYAxis {
                    AxisMarks { value in
                        AxisGridLine()
                            .foregroundStyle(.secondary.opacity(0.3))
                        
                        AxisValueLabel()
                    }
                }
            }
        }
        .onChange(of: selectedDate) { oldValue, newValue in
            if oldValue?.weekday != newValue?.weekday {
                selectedDay = newValue
            }
        }
    }
}

#Preview {
    WeightDiffBarChart(chartData: MockData.weightDiffs)
}
