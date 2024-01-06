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
    private var retrievalCompletions = [(FeedImageDataStore.RetrievalResult) -> Void]()
    private var insertionCompletion: Result<Void, Error>?
    
    func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        receivedMessages.append(.retrieve(dataForURL: url))
        retrievalCompletions.append(completion)
    }
    
    func insert(data: Data, for url: URL) throws {
        receivedMessages.append(.insert(data: data, for: url))
        try insertionCompletion?.get()
    }
    
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
    }
    
    func completeRetrieval(with error: Error, at index: Int = 0) {
        retrievalCompletions[index](.failure(error))
    }
    
    func completeRetrieval(with data: Data?, at index: Int = 0) {
        retrievalCompletions[index](.success(data))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0) {
        insertionCompletion = .failure(error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletion = .success(())
    }
}
