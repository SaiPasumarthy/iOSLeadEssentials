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

        store.completeRetrieval(with: anyNSError())
        _ = try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }

    func test_validateCache_doesnotdeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        _ = try? sut.validateCache()
        store.completeRetrievalSuccessFully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validateCache_doesnotdeleteCacheOnNonExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        
        _ = try? sut.validateCache()
        store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_validateCache_deleteCacheOnExpirationCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let expirationTimestamp = fixedCurrentDate.minusFeedCacheMaxAge()
        store.completeRetrieval(with: feed.local, timestamp: expirationTimestamp)
        
        _ = try? sut.validateCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }
    
    func test_validateCache_deleteCacheOnExpiredCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
        
        _ = try? sut.validateCache()
        
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
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrievalSuccessFully()
        }
    }
    
    func test_validateCache_succeedsOnNonExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let nonExpiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: 1)
        let (sut, store) = makeSUT(timestamp: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: feed.local, timestamp: nonExpiredTimestamp)
        }
    }
    
    func test_validateCache_failsOnDeletionErrorOfExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(timestamp: { fixedCurrentDate })
        let deletionError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(deletionError)) {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_validateCache_succeedsOnSuccessfulDeletionOfExpiredCache() {
        let feed = uniqueImageFeed()
        let fixedCurrentDate = Date()
        let expiredTimestamp = fixedCurrentDate.minusFeedCacheMaxAge().adding(seconds: -1)
        let (sut, store) = makeSUT(timestamp: { fixedCurrentDate })
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieval(with: feed.local, timestamp: expiredTimestamp)
            store.completeDeletionSuccessFully()
        }
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
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: Result<Void, Error>, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        action()
        let receivedResult = Result { try sut.validateCache() }
        switch (receivedResult, expectedResult) {
        case (.success, .success):
            break
            
        case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
            XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
        default:
            XCTFail("Expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
        }
    }
}


