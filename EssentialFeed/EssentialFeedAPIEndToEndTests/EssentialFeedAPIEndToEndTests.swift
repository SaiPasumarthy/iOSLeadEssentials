//
//  EssentialFeedAPIEndToEndTests.swift
//  EssentialFeedAPIEndToEndTests
//
//  Created by Sai Pasumarthy on 12/02/23.
//

import XCTest
import EssentialFeed

class EssentialFeedAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETResult_matchesFixedAccountData() {
         switch getFeedResult() {
            case let .success(imageFeed)?:
                XCTAssertEqual(imageFeed.count, 8)
             
            case let .failure(error)?:
                XCTFail("Expected success but got \(error) instead")
             
            default:
                XCTFail("Expected success but got no result instead")
        }
    }
    
    func test_endToEndTestServerGETFeedImageDataResult_matchesFixedTestAccountData() {
        switch getFeedImageDataResult() {
        case let .success(data)?:
            XCTAssertFalse(data.isEmpty, "Expected non-empty image data")
            
        case let .failure(error)?:
            XCTFail("Expected successful image data result, got \(error) instead")
            
        default:
            XCTFail("Expected successful image data result, got no result instead")
        }
    }
    
    //MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> RemoteFeedLoader.Result? {
        let serverUrl = URL(string: "https://www.essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let loader = RemoteFeedLoader(url: serverUrl, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        var receivedResult: RemoteFeedLoader.Result?
        let exp = expectation(description: "Wait for expectation")
        loader.load { feedResult in
            receivedResult = feedResult
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)
        return receivedResult
    }
    
    private func getFeedImageDataResult(file: StaticString = #filePath, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let testServerURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed/73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")!
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let imageLoader = RemoteFeedImageDataLoader(client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(imageLoader, file: file, line: line)
        var receivedResult: FeedImageDataLoader.Result?
        let exp = expectation(description: "Wait for expectation")
        
        _ = imageLoader.loadImageData(from: testServerURL) { imageResult in
            receivedResult = imageResult
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)
        return receivedResult
    }
}
