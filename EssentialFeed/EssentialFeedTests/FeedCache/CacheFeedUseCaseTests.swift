//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 18/02/23.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesnotReceiveMessageUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_doesnotRequestCacheInsertionUponDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        store.completeDeletion(with: deletionError)
        
        sut.save(uniqueImageFeed().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT { timestamp }
        let feed = uniqueImageFeed()
        store.completeDeletionSuccessFully()
        
        sut.save(feed.models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed.local, timestamp)])
    }
    
    func test_save_failsUponDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        expect(sut, toCompleteWithError: deletionError) {
            store.completeDeletion(with: deletionError)
        }
    }
    
    func test_save_failsUponInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessFully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_successUponSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessFully()
            store.completeInsertionSuccessFully()
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
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void,
                        file: StaticString = #file, line: UInt = #line) {
        let feed = [uniqueImage(), uniqueImage()]
        var receivedError: Error?
        
        action()
        
        sut.save(feed) { result in
            if case let Result.failure(error) = result { receivedError = error }
        }
                
        XCTAssertEqual(receivedError as? NSError, expectedError, file: file, line: line)
    }    
}
