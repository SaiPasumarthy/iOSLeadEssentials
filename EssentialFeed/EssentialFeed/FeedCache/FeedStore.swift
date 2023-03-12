//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 19/02/23.
//

import Foundation

public enum RetrievalCachedFeedResult {
    case empty
    case found(images: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias DeletionCompletion = ((Error?) -> Void)
    typealias InsertionCompletion = ((Error?) -> Void)
    typealias RetrievalCompletion = ((RetrievalCachedFeedResult) -> Void)
    
    /// The Completion handler can be invoke in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func deleteCachedFeed(with completion: @escaping DeletionCompletion)
    
    /// The Completion handler can be invoke in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion)
    
    /// The Completion handler can be invoke in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func retrieval(with completion: @escaping RetrievalCompletion)
}
