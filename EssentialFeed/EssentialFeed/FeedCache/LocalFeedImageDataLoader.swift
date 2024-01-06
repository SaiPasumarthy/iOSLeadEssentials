//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 14/05/23.
//

import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    public init(_ store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache {
    public typealias SaveResult = FeedImageDataCache.Result
    public enum SaveError: Swift.Error {
        case failed
    }
    public func save(data: Data, for url: URL, completion: @escaping (SaveResult) -> Void) {
        completion(SaveResult {
            try store.insert(data: data, for: url)
        }.mapError { _ in SaveError.failed })
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {
    public enum LoadError: Swift.Error {
        case failed
        case notFound
    }
    
    private class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        task.complete(with: Swift.Result {
            try store.retrieve(dataForURL: url)
        }
            .mapError { _ in LoadError.failed }
            .flatMap { data in
                data.map { .success($0) } ?? .failure(LoadError.notFound)
            }
        )
        return task
    }
}
