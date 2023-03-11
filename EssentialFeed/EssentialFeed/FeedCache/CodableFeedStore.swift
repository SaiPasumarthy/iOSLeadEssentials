//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 11/03/23.
//

import Foundation

public class CodableFeedStore: FeedStore {
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
    }
    private let storeURL: URL
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    
    public func retrieval(with completion: @escaping FeedStore.RetrievalCompletion) {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: storeURL) else { return completion(.empty) }
        
        do {
            let cache = try decoder.decode(Cache.self, from: data)
            completion(.found(images: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date,
                completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        do {
            let data = try encoder.encode(cache)
            try data.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func deleteCachedFeed(with completion: @escaping FeedStore.DeletionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else { return completion(nil) }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }

}
