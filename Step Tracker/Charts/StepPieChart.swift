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
    
    var chartData: [WeekdayChartData]
    
    var selectedWeekday: WeekdayChartData? {
        guard let selectedChartValue  else { return nil }
        
        var total = 0.0
        
        return chartData.first {
            total += $0.value
            return selectedChartValue <= total
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading) {
                Label("Averages", systemImage: "calendar")
                    .font(.title3.bold())
                    .foregroundStyle(.pink)
                
                Text("Last 28 days")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 12)
            
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
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

#Preview {
    StepPieChart(chartData: ChartMath.averageWeekdayCount(for: HealthMetric.mockData))
}
