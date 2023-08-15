//
//  FeedUIIntegrationTests+LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import EssentialFeed
import Foundation
import Combine

extension FeedUIIntegrationTests {
    class FeedLoaderSpy: FeedImageDataLoader {
        
        // MARK: - FeedLoader
        private var feedRequests: [PassthroughSubject<[FeedImage], Error>] = []
        var loadCallCount: Int { return feedRequests.count }
        
        func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
            let publisher = PassthroughSubject<[FeedImage], Error>()
            feedRequests.append(publisher)

            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            feedRequests[index].send(feed)
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let anyError = NSError(domain: "any error", code: 0)
            feedRequests[index].send(completion: .failure(anyError))
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
