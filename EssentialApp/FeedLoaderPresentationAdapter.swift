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
    private let feedLoader: () -> FeedLoader.Publisher
    var feedPresenter: FeedPresenter?
    init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoadingFeed()
        
        cancellable = feedLoader()
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                    
                case let .failure(error):
                    self?.feedPresenter?.didFinishLoadingFeed(with: error)
                }
            } receiveValue: { [weak self] feed in
                self?.feedPresenter?.didFinishLoadingFeed(with: feed)
            }
    }
}
