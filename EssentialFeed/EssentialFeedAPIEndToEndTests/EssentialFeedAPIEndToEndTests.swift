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
            case let .success(items):
                XCTAssertEqual(items.count, 8)
            case let .failure(error):
                XCTFail("Expected success but got \(error) instead")
            default:
                XCTFail("Expected success but got no result instead")
        }
    }
    
    //MARK: - Helpers
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> LoadFeedResult? {
        let serverUrl = URL(string: "https://www.essentialdeveloper.com/feed-case-study/test-api/feed")!
        let client = URLSessionHTTPClient()
        let loader = RemoteFeedLoader(url: serverUrl, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        var receivedResult: LoadFeedResult?
        let exp = expectation(description: "Wait for expectation")
        loader.load { feedResult in
            receivedResult = feedResult
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)
        return receivedResult
    }
}
