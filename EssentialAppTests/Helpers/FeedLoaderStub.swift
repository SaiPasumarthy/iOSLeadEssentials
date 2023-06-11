//
//  FeedLoaderStub.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 11/06/23.
//

import EssentialFeed

class FeedLoaderStub: FeedLoader {
    private let result: FeedLoader.Result
    init(result: FeedLoader.Result) {
        self.result = result
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        completion(result)
    }
}
