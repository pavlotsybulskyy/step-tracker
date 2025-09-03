//
//  STError.swift
//  Step Tracker
//
//  Created by Pavlo Tsybulskyy on 30.08.2025.
//

import Foundation

enum STError: LocalizedError {
    case authNotDetermined
    case sharedDenied(quantityType: String)
    case noData
    case unableToCompleteRequest
    case invalidValue
    
    var errorDescription: String? {
        switch self {
        case .authNotDetermined:
            return "Need access to Health Data"
        case .sharedDenied:
            return "No write access"
        case .noData:
            return "No data available."
        case .unableToCompleteRequest:
            return "Unable to complete request"
        case .invalidValue:
            return "Invalid value"
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
        case .invalidValue:
            return "Must be a numeric value with a maximum of one decimal place"
        }
    }
}
