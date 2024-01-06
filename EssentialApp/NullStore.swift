//
//  NullStore.swift
//  EssentialApp
//
//  Created by Sai Pasumarthy on 09/12/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed(with completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieval(with completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(data: Data, for url: URL) throws {
        
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }    
}
