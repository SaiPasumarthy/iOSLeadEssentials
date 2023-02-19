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
    public typealias SaveResult = Error?
    
    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.currentDate = timestamp
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
            } else {
                self.cache(items, with: completion)
            }
        }
    }
    
    private func cache(_ items: [FeedItem], with completion: @escaping (SaveResult) -> Void) {
        self.store.insert(items, timestamp: self.currentDate()) { [weak self] error in
            guard self != nil else { return }
            
            completion(error)
        }
    }
}
