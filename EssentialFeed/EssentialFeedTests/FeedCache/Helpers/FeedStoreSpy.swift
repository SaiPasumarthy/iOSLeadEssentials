//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 01/03/23.
//

import Foundation
import EssentialFeed

class FeedStoreSpy: FeedStore {    
    enum ReceivedMessage: Equatable {
        case deleteCachedFeed
        case insert([LocalFeedImage], Date)
        case retrieval
    }
    private(set) var receivedMessages = [ReceivedMessage]()
    private var deletionResult: Result<Void, Error>?
    private var insertionResult: Result<Void, Error>?
    private var retrievalResult: Result<CacheFeed?, Error>?

    func deleteCachedFeed() throws {
        receivedMessages.append(.deleteCachedFeed)
        try deletionResult?.get()
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionResult = .failure(error)
    }
    
    func completeDeletionSuccessFully(at index: Int = 0) {
        deletionResult = .success(())
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        receivedMessages.append(.insert(feed, timestamp))
        try insertionResult?.get()
    }
        
    func completeInsertionSuccessFully(at index: Int = 0) {
        insertionResult = .success(())
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func retrieval() throws -> CacheFeed? {
        receivedMessages.append(.retrieval)
        return try retrievalResult?.get()
    }
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }

    func completeRetrieval(with feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrievalResult = .success(.some(CacheFeed(images: feed, timestamp: timestamp)))
    }

    func completeRetrievalSuccessFully(at index: Int = 0) {
        retrievalResult = .success(.none)
    }
}
