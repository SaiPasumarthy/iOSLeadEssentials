//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 11/02/23.
//

import XCTest
import EssentialFeed

#warning("How this production code is free to refactor in the future to use AFNetowrking or to keep using new APIs from URLSession")
class URLSessionHTTPClient {
    private var session: URLSession
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnRequestError() {
        let url = URL(string: "https://a-url.com")!
        let error = NSError(domain: "a error", code: 1)
        URLProtocolStub.stub(url: url, error: error)
        let exp = expectation(description: "Wait for expectation")
        let sut = URLSessionHTTPClient()
        URLProtocolStub.startInterceptingRequests()
        sut.get(from: url) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected result with error \(error) got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
        URLProtocolStub.stopInterceptingRequest()
    }
    
    //MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs: [URL: Stub] = [:]
        
        private struct Stub {
            let error: Error?
        }
                
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stubs = [:]
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() { }
    }
}
