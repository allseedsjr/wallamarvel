import Foundation

enum AppErrorMapper {
    
    static func mapURLError(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost, .timedOut:
            return .network("Network connection failed: \(error.localizedDescription)")
        default:
            return .network("Network error: \(error.localizedDescription)")
        }
    }
    
    static func mapDecodingError(_ error: DecodingError) -> AppError {
        let message: String
        switch error {
        case .dataCorrupted(let context):
            message = "Data corrupted: \(context.debugDescription)"
        case .keyNotFound(let key, let context):
            message = "Missing key '\(key)': \(context.debugDescription)"
        case .typeMismatch(let type, let context):
            message = "Type mismatch for \(type): \(context.debugDescription)"
        case .valueNotFound(let type, let context):
            message = "Value not found for \(type): \(context.debugDescription)"
        @unknown default:
            message = error.localizedDescription
        }
        return .decoding(message)
    }
    
    static func mapCharacterMappingError(_ error: CharacterMappingError) -> AppError {
        switch error {
        case .invalidImageURL:
            return .invalidData("Invalid image URL in character data")
        }
    }
    
    static func map(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        if let urlError = error as? URLError {
            return mapURLError(urlError)
        }
        
        if let decodingError = error as? DecodingError {
            return mapDecodingError(decodingError)
        }
        
        if let mappingError = error as? CharacterMappingError {
            return mapCharacterMappingError(mappingError)
        }
        
        return .unknown(error.localizedDescription)
    }
}
