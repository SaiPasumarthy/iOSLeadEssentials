//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 19/02/23.
//

import Foundation

public typealias CacheFeed = (images: [LocalFeedImage], timestamp: Date)
    
public protocol FeedStore {
    func deleteCachedFeed() throws
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws
    func retrieval() throws -> CacheFeed?
}
