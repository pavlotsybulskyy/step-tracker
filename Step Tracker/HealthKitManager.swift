//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 16.08.2025.
//

import HealthKit
import Observation

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [
        HKQuantityType(.stepCount),
        HKQuantityType(.bodyMass)
    ]
}
