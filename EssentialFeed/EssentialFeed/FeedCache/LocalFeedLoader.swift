//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 19/02/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date

    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.currentDate = timestamp
    }
}

extension LocalFeedLoader {    
    private struct InvalidCache: Error {}
    public func validateCache() throws {
        do {
            if let cache = try store.retrieval(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                throw InvalidCache()
            }
        } catch {
            try store.deleteCachedFeed()
        }
    }
}

extension LocalFeedLoader: FeedCache {
    public func save(_ feed: [FeedImage]) throws {
        try store.deleteCachedFeed()
        try store.insert(feed.toLocal(), timestamp: currentDate())
    }
}

extension LocalFeedLoader {
    public func load() throws -> [FeedImage] {
        if let cache = try store.retrieval(), FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
            return cache.images.toModel()
        }
        return []
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
