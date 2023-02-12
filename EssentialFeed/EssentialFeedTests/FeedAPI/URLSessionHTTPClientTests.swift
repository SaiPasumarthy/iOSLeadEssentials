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
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { _, _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        let exp = expectation(description: "Wait for expectation")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: anyURL()) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let error = NSError(domain: "a error", code: 1)
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        let exp = expectation(description: "Wait for expectation")
        
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError.domain, error.domain)
                XCTAssertEqual(receivedError.code, error.code)
            default:
                XCTFail("Expected result with error \(error) got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnAllNilValues() {
        URLProtocolStub.stub(data: nil, response: nil, error: nil)
        
        let exp = expectation(description: "Wait for expectation")
        makeSUT().get(from: anyURL()) { result in
            switch result {
            case .failure:
                break
            default:
                XCTFail("Expected failure, got \(result) instead.")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://a-url.com")!
    }
    
    private func anyError() -> Error {
        return NSError(domain: "a error", code: 1)
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest) -> Void)?
        
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
                
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            requestObserver = observer
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() { }
    }
}
