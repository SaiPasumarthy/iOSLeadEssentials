//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 19/02/23.
//

import Foundation

public typealias CacheFeed = (images: [LocalFeedImage], timestamp: Date)
    
public protocol FeedStore {
    typealias DeletionError = Result<Void, Error>
    typealias DeletionCompletion = (DeletionError) -> Void
    
    typealias InsertionError = Result<Void, Error>
    typealias InsertionCompletion = (InsertionError) -> Void
    
    typealias RetrievalCompletion = ((RetrievalResult) -> Void)
    
    typealias RetrievalResult = Result<CacheFeed?, Error>
    
    func deleteCachedFeed() throws
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws

    func retrieval() throws -> CacheFeed?
    
    @available(*, deprecated)
    func deleteCachedFeed(with completion: @escaping DeletionCompletion)

    @available(*, deprecated)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    @available(*, deprecated)
    func retrieval(with completion: @escaping RetrievalCompletion)
}

public extension FeedStore {
    func deleteCachedFeed() throws {
        let group = DispatchGroup()
        group.enter()
        var result: DeletionError!
        deleteCachedFeed {
            result = $0
            group.leave()
        }
        group.wait()
        try result.get()
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertionError!
        insert(feed, timestamp: timestamp) {
            result = $0
            group.leave()
        }
        group.wait()
        try result.get()
    }

    func retrieval() throws -> CacheFeed? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrievalResult!
        retrieval {
            result = $0
            group.leave()
        }
        group.wait()
        return try result.get()
    }

    func deleteCachedFeed(with completion: @escaping DeletionCompletion) {}
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {}
    func retrieval(with completion: @escaping RetrievalCompletion) {}
}
