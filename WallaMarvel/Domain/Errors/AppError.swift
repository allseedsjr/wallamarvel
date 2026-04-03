import Foundation

enum AppError: Error, Equatable {
    case network(String)
    case decoding(String)
    case invalidData(String)
    case unknown(String)
    
    var userMessage: String {
        switch self {
        case .network:
            return "Network connection failed. Please check your internet and try again."
        case .decoding:
            return "Failed to process the data. Please try again."
        case .invalidData:
            return "The data received was incomplete or invalid. Please try again."
        case .unknown:
            return "Something went wrong. Please try again."
        }
    }
    
    var technicalMessage: String {
        switch self {
        case .network(let message):
            return "Network Error: \(message)"
        case .decoding(let message):
            return "Decoding Error: \(message)"
        case .invalidData(let message):
            return "Invalid Data Error: \(message)"
        case .unknown(let message):
            return "Unknown Error: \(message)"
        }
    }
}
