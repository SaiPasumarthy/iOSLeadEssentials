//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 15/04/23.
//

import EssentialFeediOS
import EssentialFeed
import Combine

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private var cancellable: Cancellable?
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    var feedPresenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoading()
        
        cancellable = feedLoader()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                    
                case let .failure(error):
                    self?.feedPresenter?.didFinishLoading(with: error)
                }
            } receiveValue: { [weak self] feed in
                self?.feedPresenter?.didFinishLoading(with: feed)
            }
    }
}
