//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 01/03/23.
//

import XCTest
import EssentialFeed

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesnotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()

        sut.load { _ in}
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrievalSuccessFully()
        }
    }
    
    func test_load_deliversCacheImagesOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        expect(sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }
    
    func test_load_deliversNoImagesOnSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }

    func test_load_deliversNoImagesOnMoreThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: -1)
        expect(sut, toCompleteWith: .success([])) {
            store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        }
    }

    func test_load_deleteCacheOnRetrievalError() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
    }
    
    func test_load_doesnotdeleteCacheOnEmptyCache() {
        let (sut, store) = makeSUT()

        sut.load { _ in }
        store.completeRetrievalSuccessFully()
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_doesnotdeleteCacheOnLessThanSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let lessThanSevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7).adding(seconds: 1)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: lessThanSevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval])
    }
    
    func test_load_deleteCacheOnSevenDaysOldCache() {
        let fixedCurrentDate = Date()
        let (sut, store) = makeSUT { fixedCurrentDate }
        let feed = uniqueImageFeed()
        let sevenDaysOldTimestamp = fixedCurrentDate.adding(days: -7)
        
        sut.load { _ in }
        store.completeRetrieval(with: feed.local, timestamp: sevenDaysOldTimestamp)
        
        XCTAssertEqual(store.receivedMessages, [.retrieval, .deleteCachedFeed])
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
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, when action: () -> Void,
                        file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedImages), .success(expectedImages)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
            case let (.failure(receivedError as NSError), .failure(expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)        
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "a error", code: 1)
    }

    private func anyURL() -> URL {
        return URL(string: "https://a-url.com")!
    }

    func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let feed = [uniqueImage(), uniqueImage()]
        let localFeed = feed.map {
            LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url)
        }
        return (feed, localFeed)
    }
}

private extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
