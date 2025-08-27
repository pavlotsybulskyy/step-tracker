//
//  StepPieChart.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 22.08.2025.
//

import SwiftUI
import Charts

struct StepPieChart: View {
    
    @State private var selectedChartValue: Double? = 0
    @State private var selectedDay: Date?
    
    var chartData: [DateValueChartData]
    
    var selectedWeekday: DateValueChartData? {
        guard let selectedChartValue  else { return nil }
        
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return selectedChartValue <= total
        }
    }
    
    var body: some View {
        let config = ChartContainerConfiguration(
            title: "Averages",
            symbol: "calendar",
            subtitle: "Last 28 days",
            context: .steps,
            isNav: false
        )
        
        ChartContainer(config: config) {
            if chartData.isEmpty {
                ChartEmptyView(
                    systemImageName: "chart.pie",
                    title: "No Data",
                    description: "There is no step count data from Health App"
                )
            } else {
                Chart {
                    ForEach(chartData) { weekday in
                        SectorMark(
                            angle: .value("Average Steps", weekday.value),
                            innerRadius: .ratio(0.618),
                            outerRadius: selectedWeekday?.date.weekday == weekday.date.weekday ? 140 : 110,
                            angularInset: 1
                        )
                        .foregroundStyle(.pink.gradient)
                        .cornerRadius(6)
                        .opacity(selectedWeekday?.date.weekday == weekday.date.weekday ? 1 : 0.3)
                    }
                }
                .chartAngleSelection(value: $selectedChartValue.animation(.easeInOut))
                .frame(height: 240)
                .chartBackground { proxy in
                    GeometryReader { geo in
                        if let plotFrame = proxy.plotFrame {
                            let frame = geo[plotFrame]
                            if let selectedWeekday {
                                VStack {
                                    Text(selectedWeekday.date.formatted(.dateTime.weekday(.wide)))
                                        .font(.title3.bold())
                                        .multilineTextAlignment(.center)
                                        .animation(nil, value: UUID())
                                    
                                    Text(selectedWeekday.value, format: .number.precision(.fractionLength(0)))
                                        .fontWeight(.medium)
                                        .foregroundStyle(.secondary)
                                        .contentTransition(.numericText())
                                }
                                .position(x: frame.midX, y: frame.midY)
                            }
                        }
                    }
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedDay)
        .onChange(of: selectedWeekday) { oldValue, newValue in
            guard let oldValue, let newValue else { return }
            if oldValue.date.weekday != newValue.date.weekday {
                selectedDay = newValue.date
            }
        }
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: MockData.steps))
}
