//
//  CodableFeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 11/03/23.
//

import Foundation
/*
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
    
    private let queue = DispatchQueue(label: "\(CodableFeedStore.self)Queue", qos: .userInitiated, attributes: .concurrent)
    
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
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else { return completion(.success(.none)) }
            
            do {
                let cache = try JSONDecoder().decode(Cache.self, from: data)
                completion(.success(.some(CacheFeed(images: cache.localFeed, timestamp: cache.timestamp))))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date,
                       completion: @escaping FeedStore.InsertionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            do {
                let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
                let data = try JSONEncoder().encode(cache)
                try data.write(to: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func deleteCachedFeed(with completion: @escaping FeedStore.DeletionCompletion) {
        let storeURL = self.storeURL
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else { return completion(.success(())) }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(.success(()))
            } catch {
                completion(.failure(error))
            }
        }
    }

}
*/
