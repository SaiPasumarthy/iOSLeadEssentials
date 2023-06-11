//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 11/06/23.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
