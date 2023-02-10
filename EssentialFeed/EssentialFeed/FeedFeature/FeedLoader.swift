//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 03/02/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
