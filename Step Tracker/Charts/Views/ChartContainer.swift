//
//  ChartContainer.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 27.08.2025.
//

import SwiftUI

enum ChartType {
    case stepBar(average: Int)
    case stepWeekdayPie
    case weightLine(average: Double)
    case weightDiffBar
}

struct ChartContainer<Content: View>: View {
    let chartType: ChartType
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading) {
            if isNav {
                navigationLinkView
            } else {
                titleView
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 12)
            }
            
            content()
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
    
    var navigationLinkView: some View {
        NavigationLink(value: context) {
            HStack {
                titleView
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
        .foregroundStyle(.secondary)
        .padding(.bottom, 12)
        .accessibilityHint("Tap for data in list view")
    }
    
    var titleView: some View {
        VStack(alignment: .leading) {
            Label(title, systemImage: symbol)
                .font(.title3.bold())
                .foregroundStyle(context == .steps ? .pink : .indigo)
            
            Text(subtitle)
                .font(.caption)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(accessibilityLabel)
        .accessibilityElement(children: .ignore)
    }
}

extension ChartContainer {
    var isNav: Bool {
        switch chartType {
        case .stepBar,
                .weightLine:
            return true
        case .stepWeekdayPie,
                .weightDiffBar:
            return false
        }
    }
    
    var context: HealthMetricContext {
        switch chartType {
        case .stepBar,
                .stepWeekdayPie:
            return .steps
        case .weightLine,
                .weightDiffBar:
            return .weight
        }
    }
    
    var title: String {
        switch chartType {
        case .stepBar:
            "Steps"
        case .stepWeekdayPie:
            "Averages"
        case .weightLine:
            "Weight"
        case .weightDiffBar:
            "Averagee Weight Change"
        }
    }
    
    var subtitle: String {
        switch chartType {
        case .stepBar(let average):
            "Average \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Last 28 days"
        case .weightLine(average: let average):
            "Average: \(average.formatted(.number.precision(.fractionLength(1))))"
        case .weightDiffBar:
            "Per Weekday (Last 28 days)"
        }
    }
    
    var symbol: String {
        switch chartType {
        case .stepBar:
            "figure.walk"
        case .stepWeekdayPie:
            "calendar"
        case .weightLine,
                .weightDiffBar:
            "figure"
        }
    }
    
    var accessibilityLabel: String {
        switch chartType {
        case .stepBar(let average):
            "Bar chart, step count, last 28 days, average steps per day: \(average.formatted()) steps"
        case .stepWeekdayPie:
            "Pie chart, average steps per weekday"
        case .weightLine(average: let average):
            "Line chart, weight, average weight: \(average.formatted(.number.precision(.fractionLength(1)))) pounds, goal weight: 155 pounds"
        case .weightDiffBar:
            "Bar chart, avarage weight difference per weekday"
        }
    }
}

#Preview {
    ChartContainer(chartType: .stepWeekdayPie) {
        Text("Chart")
            .frame(height: 150)
    }
}
