//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 04/02/23.
//

import XCTest
class RemoteFeedLoader {
    
}
class HTTPClient {
    var requestedURL: URL?
}
class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL() {
        let client = HTTPClient()
        _ = RemoteFeedLoader()
        
        XCTAssertNil(client.requestedURL)
    }
}
