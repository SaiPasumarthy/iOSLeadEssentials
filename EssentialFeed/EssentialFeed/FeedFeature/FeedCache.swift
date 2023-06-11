//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 11/06/23.
//

import Foundation

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
