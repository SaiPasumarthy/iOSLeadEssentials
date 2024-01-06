//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 11/06/23.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}
