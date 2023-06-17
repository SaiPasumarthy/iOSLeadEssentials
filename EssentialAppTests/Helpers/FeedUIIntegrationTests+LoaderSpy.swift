//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import EssentialFeed
import Foundation

extension FeedUIIntegrationTests {
    class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        private var feedRequests: [(FeedLoader.Result) -> Void] = []
        var loadCallCount: Int { return feedRequests.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let anyError = NSError(domain: "any error", code: 0)
            feedRequests[index](.failure(anyError))
        }
        
        // MARK: - FeedImageDataLoader
        private(set) var cancelledImageURLs = [URL]()
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        private var imageRequests: [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)] = []

        private struct TaskSpy: FeedImageDataLoaderTask {
            let cacelCallBack: () -> Void
            func cancel() {
                cacelCallBack()
            }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
        
        func completeImageLoading(_ data: Data = Data(), at index: Int) {
            imageRequests[index].completion(.success(data))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            let anyError = NSError(domain: "any error", code: 0)
            imageRequests[index].completion(.failure(anyError))
        }
    }
}
