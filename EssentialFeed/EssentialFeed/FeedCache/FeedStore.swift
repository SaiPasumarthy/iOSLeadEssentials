//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 19/02/23.
//

import Foundation

public typealias CacheFeed = (images: [LocalFeedImage], timestamp: Date)
    
public protocol FeedStore {
    typealias DeletionError = Error?
    typealias DeletionCompletion = (DeletionError) -> Void
    
    typealias InsertionError = Error?
    typealias InsertionCompletion = (InsertionError) -> Void
    
    typealias RetrievalCompletion = ((RetrievalResult) -> Void)
    
    typealias RetrievalResult = Result<CacheFeed?, Error>
    
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
