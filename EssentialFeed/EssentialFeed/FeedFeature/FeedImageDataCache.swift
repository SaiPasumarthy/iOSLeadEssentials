//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 11/06/23.
//

import Foundation

public protocol FeedImageDataCache {
    func save(data: Data, for url: URL) throws
}
