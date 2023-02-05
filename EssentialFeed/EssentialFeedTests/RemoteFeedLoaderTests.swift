//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 04/02/23.
//

import XCTest
import EssentialFeed

// Test name is like test_<methodName>_<behaviourToTest>
class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertNil(client.requestedURL)
    }
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url-given.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURL: URL?

        func get(from url: URL) {
            requestedURL = url
        }
    }
}
