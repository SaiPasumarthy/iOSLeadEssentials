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
        
        try? sut.save(uniqueImageFeed().models)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let (sut, store) = makeSUT { timestamp }
        let feed = uniqueImageFeed()
        store.completeDeletionSuccessFully()
        
        try? sut.save(feed.models)
        
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
        
        action()
        var receivedError: NSError?
        
        do {
            try sut.save(feed)
        } catch {
            receivedError = error as NSError?
        }
        
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
    }
}
