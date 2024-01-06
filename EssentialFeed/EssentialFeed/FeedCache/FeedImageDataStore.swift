//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 14/05/23.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
