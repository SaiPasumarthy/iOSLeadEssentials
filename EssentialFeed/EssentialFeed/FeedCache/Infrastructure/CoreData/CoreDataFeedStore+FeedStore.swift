//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 03/06/23.
//

import Foundation

extension CoreDataFeedStore: FeedStore {
    public func deleteCachedFeed() throws {
        try performSync { context in
            Result {
                try ManagedCache.deleteCache(in: context)
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        try performSync { context in
            Result {
                let managedCache = try ManagedCache.newUniqueInstance(in: context)
                managedCache.timestamp = timestamp
                managedCache.feed = ManagedFeedImage.images(from: feed, in: context)

                try context.save()
            }
        }
    }
    
    public func retrieval() throws -> CacheFeed? {
        try performSync { context in
            Result {
                try ManagedCache.find(in: context).map {
                    CacheFeed(images: $0.localFeed, timestamp: $0.timestamp)
                }
            }
        }
    }
}
