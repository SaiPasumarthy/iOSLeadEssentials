//
//  ValidateFeedCacheUseCasesTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 06/03/23.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCasesTests: XCTestCase {
    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }

    func test_validateCache_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.validateCache { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }

    func test_validateCache_doesnotdeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.validateCache { _ in }
        store.completeRetrievalSuccessFully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validateCache_doesnotdeleteCacheOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validateCache_deleteCacheOnExpirationCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }
    
    func test_validateCache_deleteCacheOnExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        
        sut.validateCache { _ in }
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }
    
    func test_validateCache_failsOnDeletionErrorOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfFailedRetrieval() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: anyNSError())
            store.completeDeletionSuccessFully()
        }
    }
    
    func test_validateCache_doesnotDeleteInvalidCacheAfterSUTInstanceHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: Date.init)
        
        sut?.validateCache { _ in }
        sut = nil
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    //MARK: - Helpers
    
    private func makeSUT(timestamp: @escaping () -> Date = Date.init,
                 file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.ValidationResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success, .success):
                break
                
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
}


