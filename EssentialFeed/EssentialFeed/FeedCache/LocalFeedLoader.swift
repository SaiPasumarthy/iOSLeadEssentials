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
    public typealias ValidationResult = Result<Void, Error>
    
    private struct InvalidCache: Error {}
    public func validateCache(completion: @escaping (ValidationResult) -> Void) {
        
        completion(ValidationResult {
            do {
                if let cache = try store.retrieval(), !FeedCachePolicy.validate(cache.timestamp, against: currentDate()) {
                    throw InvalidCache()
                }
            } catch {
                try store.deleteCachedFeed()
            }
        })
    }
}

extension LocalFeedLoader: FeedCache {
    public typealias SaveResult = FeedCache.Result

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        completion(SaveResult {
            try store.deleteCachedFeed()
            try store.insert(feed.toLocal(), timestamp: currentDate())
        })
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = Swift.Result<[FeedImage], Error>

    public func load(completion: @escaping (LoadResult) -> Void) {
        completion(LoadResult {
            if let cache = try store.retrieval(), FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
                return cache.images.toModel()
            }
            return []
        })
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
