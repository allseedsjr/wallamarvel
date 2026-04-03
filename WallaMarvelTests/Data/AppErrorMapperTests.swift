import XCTest
@testable import WallaMarvel

final class AppErrorMapperTests: XCTestCase {
    
    func test_mapURLError_withNotConnectedToInternet_returnsNetworkError() {
        let urlError = URLError(.notConnectedToInternet)
        
        let result = AppErrorMapper.mapURLError(urlError)
        
        if case .network = result {
        } else {
            XCTFail("Expected network error")
        }
    }
    
    func test_mapURLError_withNetworkConnectionLost_returnsNetworkError() {
        let urlError = URLError(.networkConnectionLost)
        
        let result = AppErrorMapper.mapURLError(urlError)
        
        if case .network = result {
        } else {
            XCTFail("Expected network error")
        }
    }
    
    func test_mapURLError_withTimedOut_returnsNetworkError() {
        let urlError = URLError(.timedOut)
        
        let result = AppErrorMapper.mapURLError(urlError)
        
        if case .network = result {
        } else {
            XCTFail("Expected network error")
        }
    }
    
    func test_mapDecodingError_returnsDecodingError() {
        let invalidJSON = Data("invalid".utf8)
        let decoder = JSONDecoder()
        
        do {
            _ = try decoder.decode(CharacterDataContainer.self, from: invalidJSON)
            XCTFail("Should have thrown DecodingError")
        } catch let decodingError as DecodingError {
            let result = AppErrorMapper.mapDecodingError(decodingError)
            
            if case .decoding = result {
            } else {
                XCTFail("Expected decoding error")
            }
        } catch {
            XCTFail("Expected DecodingError")
        }
    }
    
    func test_mapCharacterMappingError_invalidImageURL_returnsInvalidDataError() {
        let mappingError = CharacterMappingError.invalidImageURL
        
        let result = AppErrorMapper.mapCharacterMappingError(mappingError)
        
        if case .invalidData = result {
        } else {
            XCTFail("Expected invalidData error")
        }
    }
    
    func test_map_withAppError_returnsAppErrorAsIs() {
        let appError = AppError.network("Connection failed")
        
        let result = AppErrorMapper.map(appError)
        
        XCTAssertEqual(result, appError)
    }
    
    func test_map_withURLError_returnsNetworkError() {
        let urlError = URLError(.timedOut)
        
        let result = AppErrorMapper.map(urlError)
        
        if case .network = result {
        } else {
            XCTFail("Expected network error")
        }
    }
    
    func test_map_withGenericError_returnsUnknownError() {
        let genericError = NSError(domain: "Some domain", code: -1)
        
        let result = AppErrorMapper.map(genericError)
        
        if case .unknown = result {
        } else {
            XCTFail("Expected unknown error")
        }
    }
}
