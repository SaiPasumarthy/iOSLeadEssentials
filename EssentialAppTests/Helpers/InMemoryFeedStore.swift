//
//  InMemoryFeedStore.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import Foundation
import EssentialFeed

class InMemoryFeedStore: FeedStore, FeedImageDataStore {
    private(set) var feedCache: CacheFeed?
    private var feedImageDataCache: [URL: Data] = [:]
    
    private init(feedCache: CacheFeed? = nil) {
        self.feedCache = feedCache
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {
        feedCache = CacheFeed(images: feed, timestamp: timestamp)
    }

    func deleteCachedFeed() throws {
        feedCache = nil
    }
    
    func retrieval() throws -> CacheFeed? {
        feedCache
    }
    
    func insert(data: Data, for url: URL) throws {
        feedImageDataCache[url] = data
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        feedImageDataCache[url]
    }
    
    static var empty: InMemoryFeedStore {
        InMemoryFeedStore()
    }
    
    static var withExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(images: [], timestamp: Date.distantPast))
    }
    
    static var withNonExpiredFeedCache: InMemoryFeedStore {
        InMemoryFeedStore(feedCache: CacheFeed(images: [], timestamp: Date()))
    }
}
