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
    
    private func getFeedResult(file: StaticString = #filePath, line: UInt = #line) -> Swift.Result<[FeedImage], Error>? {
        let client = ephemeralClient()
        var receivedResult: Swift.Result<[FeedImage], Error>?
        let exp = expectation(description: "Wait for expectation")
        client.get(from: feedTestServerURL) { feedResult in
            receivedResult = feedResult.flatMap { (data, response) in
                do {
                    return .success(try FeedItemMapper.map(data, from: response))
                } catch {
                    return .failure(error)
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)
        return receivedResult
    }
    
    private func getFeedImageDataResult(file: StaticString = #filePath, line: UInt = #line) -> FeedImageDataLoader.Result? {
        let testServerURL = feedTestServerURL.appendingPathComponent("73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6/image")
        let client = ephemeralClient()
        var receivedResult: FeedImageDataLoader.Result?
        let exp = expectation(description: "Wait for expectation")
        
        _ = client.get(from: testServerURL) { imageResult in
            receivedResult = imageResult.flatMap({ (data, response) in
                do {
                    return .success(try FeedImageDataMapper.map(data, from: response))
                } catch {
                    return .failure(error)
                }
            })
            exp.fulfill()
        }
        wait(for: [exp], timeout: 15.0)
        return receivedResult
    }
    
    private var feedTestServerURL: URL {
        return URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
    }
    
    private func ephemeralClient(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        trackForMemoryLeaks(client, file: file, line: line)
        return client
    }
}
