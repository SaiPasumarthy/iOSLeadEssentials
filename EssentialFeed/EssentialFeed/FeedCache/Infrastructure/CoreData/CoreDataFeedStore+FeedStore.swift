//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 03/06/23.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func deleteCachedFeed(with completion: @escaping DeletionCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        perform { context in
            completion(Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
            })
        }
    }
    
    public func retrieval(with completion: @escaping RetrievalCompletion) {
        perform { context in
            completion(Result {
                try ManagedCache.find(in: context).map {
                    CacheFeed(images: $0.localFeed, timestamp: $0.timestamp)
                }
            })
        }
    }
}
