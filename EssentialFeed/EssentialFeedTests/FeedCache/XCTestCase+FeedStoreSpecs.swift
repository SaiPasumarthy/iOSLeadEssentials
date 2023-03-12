//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 12/03/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrive expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for expectation")
        sut.retrieval { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(receivedImages, receivedTimestamp), .found(expectedImages, expectedTimestamp)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected empty but got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for expectation")
        var insertionError: Error? = nil
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for expectation")
        var deleteError: Error? = nil
        sut.deleteCachedFeed { receivedError in
            deleteError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deleteError
    }
}
