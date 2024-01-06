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
    class FeedLoaderSpy {
        
        // MARK: - FeedLoader
        private var feedRequests: [PassthroughSubject<Paginated<FeedImage>, Error>] = []
        private var loadMoreRequests: [PassthroughSubject<Paginated<FeedImage>, Error>] = []
        
        var loadCallCount: Int { return feedRequests.count }
        var loadMoreCallCount: Int { return loadMoreRequests.count }
        
        func loadPublisher() -> AnyPublisher<Paginated<FeedImage>, Error> {
            let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
            feedRequests.append(publisher)

            return publisher.eraseToAnyPublisher()
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            feedRequests[index].send(Paginated(items: feed, loadMorePublisher: { [weak self] in
                let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                self?.loadMoreRequests.append(publisher)
                
                return publisher.eraseToAnyPublisher()
            }))
            
            feedRequests[index].send(completion: .finished)
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let anyError = NSError(domain: "any error", code: 0)
            feedRequests[index].send(completion: .failure(anyError))
        }
        
        func completeLoadMore(with feed: [FeedImage] = [], lastPage: Bool = false, at index: Int) {
            loadMoreRequests[index].send(Paginated(
                items: feed,
                loadMorePublisher: lastPage ? nil : { [weak self] in
                    let publisher = PassthroughSubject<Paginated<FeedImage>, Error>()
                    self?.loadMoreRequests.append(publisher)
                    
                    return publisher.eraseToAnyPublisher()
                }))
        }
        
        func completeLoadMoreWithError(at index: Int = 0) {
            let anyError = NSError(domain: "any error", code: 0)
            loadMoreRequests[index].send(completion: .failure(anyError))
        }
        
        // MARK: - FeedImageDataLoader
                
        private var imageRequests = [(url: URL, publisher: PassthroughSubject<Data, Error>)]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageDataPublisher(from url: URL) -> AnyPublisher<Data, Error> {
            let publisher = PassthroughSubject<Data, Error>()
            imageRequests.append((url, publisher))
            return publisher.handleEvents(receiveCancel: { [weak self] in
                self?.cancelledImageURLs.append(url)
            }).eraseToAnyPublisher()
        }
        
        func completeImageLoading(_ imageData: Data = Data(), at index: Int = 0) {
            imageRequests[index].publisher.send(imageData)
            imageRequests[index].publisher.send(completion: .finished)
        }
        
        func completeImageLoadingWithError(at index: Int = 0) {
            imageRequests[index].publisher.send(completion: .failure(anyNSError()))
        }
    }
}
