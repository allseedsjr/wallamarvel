import Foundation

final class URLProtocolStub: URLProtocol {
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }

    static var stub: Stub?

    static func startIntercepting(with stub: Stub) {
        self.stub = stub
    }

    static func stopIntercepting() {
        stub = nil
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let stub = URLProtocolStub.stub else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        stub.requestObserver?(request)

        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }
}
