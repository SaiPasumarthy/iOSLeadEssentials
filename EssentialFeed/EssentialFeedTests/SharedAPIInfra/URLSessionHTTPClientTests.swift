//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 11/02/23.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClientTests: XCTestCase {
        
    override func tearDown() {
        super.tearDown()
        
        URLProtocolStub.removeStub()
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
        let requestError = anyNSError()
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError)) as? NSError
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_successOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let result = resultValuesFor((data: data, response: response, error: nil))

        XCTAssertEqual(result?.data, data)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
}
    
    func test_getFromURL_successWithEmptyDataOnHTTPURLResponse() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        URLProtocolStub.stub(data: nil, response: response, error: nil)
        
        let result = resultValuesFor((data: nil, response: response, error: nil))
        
        XCTAssertEqual(result?.data, emptyData)
        XCTAssertEqual(result?.response.url, response.url)
        XCTAssertEqual(result?.response.statusCode, response.statusCode)
    }
    
    func test_cancelGetFromURLTask_cancelsURLRequest() {
        let exp = expectation(description: "Wait for request")
        URLProtocolStub.observeRequests { _ in exp.fulfill() }
        
        let receivedError = resultErrorFor { task in task.cancel() } as NSError?
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
    }
    
    //MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil,
                                taskHanlder: (HTTPClientTask) -> Void = { _ in },
                                file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHanlder: taskHanlder, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure got \(result) instead.", file: file, line: line)
            return nil
        }
    }
    
    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?),
                                  file: StaticString = #filePath, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success got \(result) instead.", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?,
                                 taskHanlder: (HTTPClientTask) -> Void = { _ in },
                            file: StaticString = #filePath, line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        let sut = makeSUT()
        let exp = expectation(description: "Wait for expectation")
        
        var receivedResult: HTTPClient.Result!
        taskHanlder(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://a-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "a error", code: 1)
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
}
