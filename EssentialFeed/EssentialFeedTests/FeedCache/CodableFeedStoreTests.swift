//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 11/03/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    func retrieval(with completion: @escaping FeedStore.RetrievalCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {

    func test_retrieval_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for expectation")
        sut.retrieval { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty but got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieval_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "Wait for expectation")
        sut.retrieval { firstResult in
            sut.retrieval { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty but got \(firstResult) and \(secondResult)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
