//
//  XCTestCase+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 12/03/23.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func expect(_ sut: FeedStore, toRetriveTwice expectedResult: FeedStore.RetrievalResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    func expect(_ sut: FeedStore, toRetrive expectedResult: Result<CacheFeed?, Error>, file: StaticString = #filePath, line: UInt = #line) {
        let receivedResult = Result { try sut.retrieval() }
        
        switch (receivedResult, expectedResult) {
        case (.success(.none), .success(.none)), (.failure, .failure):
            break
        case let (.success(.some(retrieved)), .success(.some(expected))):
            XCTAssertEqual(retrieved.images, expected.images, file: file, line: line)
            XCTAssertEqual(retrieved.timestamp, expected.timestamp, file: file, line: line)
        default:
            XCTFail("Expected empty but got \(receivedResult)", file: file, line: line)
        }
    }
    
    @discardableResult
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        do {
            try sut.insert(cache.feed, timestamp: cache.timestamp)
            return .none
        } catch {
            return error
        }
    }
    
    func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        do {
            try sut.deleteCachedFeed()
            return .none
        } catch {
            return error
        }        
    }
}
