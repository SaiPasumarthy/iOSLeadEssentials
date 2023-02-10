//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 03/02/23.
//

import Foundation

public enum LoadFeedResult<Error: Swift.Error> {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    associatedtype Error: Swift.Error
    
    func loadFeed(completion: @escaping (LoadFeedResult<Error>) -> Void)
}
