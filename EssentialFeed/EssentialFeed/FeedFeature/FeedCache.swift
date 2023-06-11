//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 11/06/23.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
