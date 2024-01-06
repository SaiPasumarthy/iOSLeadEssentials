//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 14/05/23.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    public init(_ store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public enum SaveError: Swift.Error {
        case failed
    }
    public func save(data: Data, for url: URL) throws {
        do {
            try store.insert(data: data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL) throws -> Data {
        do {
            if let imageData = try store.retrieve(dataForURL: url) {
                return imageData
            }
        } catch {
            throw LoadError.failed
        }
        
        throw LoadError.notFound
    }
}
