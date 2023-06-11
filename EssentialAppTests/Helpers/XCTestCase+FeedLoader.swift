//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 11/06/23.
//

import XCTest
import EssentialFeed

protocol FeedLoaderTestCase: XCTestCase {
}

extension FeedLoaderTestCase {
    func expect(sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Waiting for load completion")
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
}
