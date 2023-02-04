//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 04/02/23.
//

import XCTest
#warning("How client of RemoteFeedLoader doesn't knows about HTTPClient when it dependancy injects through init")
class RemoteFeedLoader {
    let client: HTTPClient
    init(client: HTTPClient) {
        self.client = client
    }
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}
protocol HTTPClient {
    func get(from url: URL)
}
class HTTPClientSpy: HTTPClient {
    var requestedURL: URL?

    func get(from url: URL) {
        requestedURL = url
    }
}
class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL() {
        let client = HTTPClientSpy()
        _ = RemoteFeedLoader(client: client)
        
        XCTAssertNil(client.requestedURL)
    }
    func test_load_requestDataFromURL() {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client)
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
}
