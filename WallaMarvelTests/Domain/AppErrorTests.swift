import XCTest
@testable import WallaMarvel

final class AppErrorTests: XCTestCase {
    
    func test_networkError_userMessage_isFriendly() {
        let error = AppError.network("Some network issue")
        
        let userMessage = error.userMessage
        
        XCTAssertEqual(userMessage, "Network connection failed. Please check your internet and try again.")
    }
    
    func test_decodingError_userMessage_isFriendly() {
        let error = AppError.decoding("Invalid JSON")
        
        let userMessage = error.userMessage
        
        XCTAssertEqual(userMessage, "Failed to process the data. Please try again.")
    }
    
    func test_invalidDataError_userMessage_isFriendly() {
        let error = AppError.invalidData("Missing fields")
        
        let userMessage = error.userMessage
        
        XCTAssertEqual(userMessage, "The data received was incomplete or invalid. Please try again.")
    }
    
    func test_unknownError_userMessage_isFriendly() {
        let error = AppError.unknown("Something happened")
        
        let userMessage = error.userMessage
        
        XCTAssertEqual(userMessage, "Something went wrong. Please try again.")
    }
    
    func test_networkError_technicalMessage_includesTechnicalDetails() {
        let error = AppError.network("Timeout after 30 seconds")
        
        let technicalMessage = error.technicalMessage
        
        XCTAssertTrue(technicalMessage.contains("Network Error"))
        XCTAssertTrue(technicalMessage.contains("Timeout after 30 seconds"))
    }
    
    func test_decodingError_technicalMessage_includesTechnicalDetails() {
        let error = AppError.decoding("Expected String, got Number")
        
        let technicalMessage = error.technicalMessage
        
        XCTAssertTrue(technicalMessage.contains("Decoding Error"))
        XCTAssertTrue(technicalMessage.contains("Expected String"))
    }
    
    func test_invalidDataError_technicalMessage_includesTechnicalDetails() {
        let error = AppError.invalidData("ID is missing")
        
        let technicalMessage = error.technicalMessage
        
        XCTAssertTrue(technicalMessage.contains("Invalid Data Error"))
        XCTAssertTrue(technicalMessage.contains("ID is missing"))
    }
    
    func test_unknownError_technicalMessage_includesTechnicalDetails() {
        let error = AppError.unknown("Random failure")
        
        let technicalMessage = error.technicalMessage
        
        XCTAssertTrue(technicalMessage.contains("Unknown Error"))
        XCTAssertTrue(technicalMessage.contains("Random failure"))
    }
    
    func test_appErrorEquatable_twoNetworkErrorsWithSameMessage_areEqual() {
        let error1 = AppError.network("Connection failed")
        let error2 = AppError.network("Connection failed")
        
        XCTAssertEqual(error1, error2)
    }
    
    func test_appErrorEquatable_twoErrorsOfDifferentTypes_areNotEqual() {
        let error1 = AppError.network("Connection failed")
        let error2 = AppError.unknown("Something happened")
        
        XCTAssertNotEqual(error1, error2)
    }
}
