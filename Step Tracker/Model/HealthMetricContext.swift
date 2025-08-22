//
//  HealthMetricContext.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 22.08.2025.
//

import Foundation

enum HealthMetricContext: CaseIterable, Identifiable {
    case steps
    case weight
    
    var id: Self { self }
    
    var title: String {
        switch self {
        case .steps:
            return "Steps"
        case .weight:
            return "Weight"
        }
    }
}
