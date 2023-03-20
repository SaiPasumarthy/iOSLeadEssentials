//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 19/02/23.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    #warning("Why currentDate is a clousure instead of just Date type let currentDate: Date")
    private let currentDate: () -> Date

    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.currentDate = timestamp
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieval { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .success(.found(_, timestamp)) where !FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                self.store.deleteCachedFeed { _ in }
            case .success: break
            }
        }
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?

    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    public typealias LoadResult = FeedLoader.Result

    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieval { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.found(feed, timestamp)) where FeedCachePolicy.validate(timestamp, against: self.currentDate()):
                completion(.success(feed.toModel()))
            case .success:
                completion(.success([]))
            }
        }
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
