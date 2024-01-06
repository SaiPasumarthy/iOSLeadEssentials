//
//  NullStore.swift
//  EssentialApp
//
//  Created by Sai Pasumarthy on 09/12/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore {
    func deleteCachedFeed() throws {}
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws {}

    func retrieval() throws -> CacheFeed? {
        .none
    }

}

extension NullStore: FeedImageDataStore {
    func insert(data: Data, for url: URL) throws {}
    func retrieve(dataForURL url: URL) throws -> Data? {
        .none
    }
}
