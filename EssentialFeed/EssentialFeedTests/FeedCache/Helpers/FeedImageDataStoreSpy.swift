//
//  FeedImageDataStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 14/05/23.
//

import EssentialFeed
import Foundation

class FeedImageDataStoreSpy: FeedImageDataStore {
    enum Message: Equatable {
        case insert(data: Data, for: URL)
        case retrieve(dataForURL: URL)
    }
    private(set) var receivedMessages = [Message]()
    private var retrievalResult: Result<Data?, Error>?
    private var insertionResult: Result<Void, Error>?
    
    func insert(data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionResult?.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        receivedMessages.append(.retrieve(dataForURL: url))
        return try retrievalResult?.get()
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalResult = .failure(error)
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalResult = .success(data)
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionResult = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionResult = .success(())
    }
}
