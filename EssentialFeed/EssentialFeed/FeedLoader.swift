//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 03/02/23.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
