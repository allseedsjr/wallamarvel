import Foundation

final class URLProtocolStub: URLProtocol {
    struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Error?
        let requestObserver: ((URLRequest) -> Void)?
    }

    static var stub: Stub?
    private static var stubSequence: [Stub] = []
    private static var sequenceIndex = 0
    private static let lock = NSLock()

    static func startIntercepting(with stub: Stub) {
        self.stub = stub
        stubSequence = []
        sequenceIndex = 0
    }

    static func startIntercepting(withSequence stubs: [Stub]) {
        stub = nil
        lock.lock()
        stubSequence = stubs
        sequenceIndex = 0
        lock.unlock()
    }

    static func stopIntercepting() {
        stub = nil
        lock.lock()
        stubSequence = []
        sequenceIndex = 0
        lock.unlock()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        let currentStub = resolveStub()

        guard let currentStub else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        currentStub.requestObserver?(request)

        if let response = currentStub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = currentStub.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let error = currentStub.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() { }

    private func resolveStub() -> Stub? {
        if let stub = URLProtocolStub.stub {
            return stub
        }
        URLProtocolStub.lock.lock()
        defer { URLProtocolStub.lock.unlock() }
        guard URLProtocolStub.sequenceIndex < URLProtocolStub.stubSequence.count else { return nil }
        let stub = URLProtocolStub.stubSequence[URLProtocolStub.sequenceIndex]
        URLProtocolStub.sequenceIndex += 1
        return stub
    }
}
