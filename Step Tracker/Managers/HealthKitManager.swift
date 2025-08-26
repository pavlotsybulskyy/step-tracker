//
//  HealthKitManager.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 16.08.2025.
//

import HealthKit
import Observation

enum STError: LocalizedError {
    case authNotDetermined
    case sharedDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            return "Need access to Health Data"
        case .sharedDenied(quantityType: let type):
            return "No write access"
        case .noData:
            return "No data available."
        case .unableToCompleteRequest:
            return "Unable to complete request"
        }
    }
    
    var failureReason: String {
        switch self {
        case .authNotDetermined:
            return "You have not given access to your Health data. Please go to Settings > Health > Data access & Devices."
        case .sharedDenied(let quantityType):
            return "You have denied access to upload your \(quantityType) data.\n\nPlease go to Settings > Health > Data access & Devices."
        case .noData:
            return "There is no data for this Health statistic"
        case .unableToCompleteRequest:
            return "We are unable to complete your request at this time.\n\nPlease try again later or contact support"
        }
    }
}

@Observable class HealthKitManager {
    
    let store = HKHealthStore()
    
    let types: Set = [
        HKQuantityType(.stepCount),
        HKQuantityType(.bodyMass)
    ]
    
    var stepData: [HealthMetric] = []
    var weightData: [HealthMetric] = []
    var weightDiffData: [HealthMetric] = []
    
    func fetchStepCount() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.stepCount)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate
        )
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.stepCount),
            predicate: queryPredicate
        )
        
        let stepsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .cumulativeSum,
            anchorDate: endDate,
            intervalComponents: .init(day: 1)
        )
        
        do {
            let stepCounts = try await stepsQuery.result(for: store)
            stepData = stepCounts.statistics().map {
                HealthMetric(
                    date: $0.startDate,
                    value: $0.sumQuantity()?.doubleValue(for: .count()) ?? 0
                )
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    func fetchWeightsCount() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -28, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate
        )
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.bodyMass),
            predicate: queryPredicate
        )
        
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: .init(day: 1)
        )
        
        do {
            let weights = try await weightsQuery.result(for: store)
            weightData = weights.statistics().map {
                HealthMetric(
                    date: $0.startDate,
                    value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0
                )
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    func fetchWeightForDifferencials() async throws {
        guard store.authorizationStatus(for: HKQuantityType(.bodyMass)) != .notDetermined else {
            throw STError.authNotDetermined
        }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let endDate = calendar.date(byAdding: .day, value: 1, to: today)!
        let startDate = calendar.date(byAdding: .day, value: -29, to: endDate)!
        
        let queryPredicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: endDate
        )
        let samplePredicate = HKSamplePredicate.quantitySample(
            type: HKQuantityType(.bodyMass),
            predicate: queryPredicate
        )
        
        let weightsQuery = HKStatisticsCollectionQueryDescriptor(
            predicate: samplePredicate,
            options: .mostRecent,
            anchorDate: endDate,
            intervalComponents: .init(day: 1)
        )
        
        do {
            let weights = try await weightsQuery.result(for: store)
            weightDiffData = weights.statistics().map {
                HealthMetric(
                    date: $0.startDate,
                    value: $0.mostRecentQuantity()?.doubleValue(for: .pound()) ?? 0
                )
            }
        } catch HKError.errorNoData {
            throw STError.noData
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    func addStepData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.stepCount))
        
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharedDenied(quantityType: "Step count")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let stepQuantity = HKQuantity(unit: .count(), doubleValue: value)
        let stepSample = HKQuantitySample(
            type: HKQuantityType(.stepCount),
            quantity: stepQuantity,
            start: date,
            end: date
        )
        
        do {
            try await store.save(stepSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
    func addWeightData(for date: Date, value: Double) async throws {
        let status = store.authorizationStatus(for: HKQuantityType(.bodyMass))
        
        switch status {
        case .notDetermined:
            throw STError.authNotDetermined
        case .sharingDenied:
            throw STError.sharedDenied(quantityType: "Weight")
        case .sharingAuthorized:
            break
        @unknown default:
            break
        }
        
        let weightQuantity = HKQuantity(unit: .pound(), doubleValue: value)
        let weightSample = HKQuantitySample(
            type: HKQuantityType(.bodyMass),
            quantity: weightQuantity,
            start: date,
            end: date
        )
        
        do {
            try await store.save(weightSample)
        } catch {
            throw STError.unableToCompleteRequest
        }
    }
    
//    func addSimulatorData() async {
//        var mockSamples: [HKQuantitySample] = []
//        
//        for i in 0..<28  {
//            let stepQuantity = HKQuantity(unit: .count(), doubleValue: .random(in: 4_000...20_000))
//            let weightQuantity = HKQuantity(unit: .pound(), doubleValue: .random(in: (160 + Double(i/3)...165 + Double(i/3))))
//            
//            let startDate = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
//            let endDate = Calendar.current.date(byAdding: .second, value: 1, to: startDate)!
//            
//            let stepSample = HKQuantitySample(
//                type: HKQuantityType(.stepCount),
//                quantity: stepQuantity,
//                start: startDate,
//                end: endDate
//            )
//            
//            let weightSample = HKQuantitySample(
//                type: HKQuantityType(.bodyMass),
//                quantity: weightQuantity,
//                start: startDate,
//                end: endDate
//            )
//            
//            mockSamples.append(stepSample)
//            mockSamples.append(weightSample)
//        }
//        
//        try! await store.save(mockSamples)
//        print("✅ Dummy data added!")
//    }
}
