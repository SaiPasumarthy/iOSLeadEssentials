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
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed.count, 8)
            case let .failure(error):
                XCTFail("Expected success but got \(error) instead")
            default:
                XCTFail("Expected success but got no result instead")
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
}
