//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 06/04/23.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(viewModel: FeedViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

final class FeedPresenter {
    private var feedLoader: FeedLoader?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    var loadingView: FeedLoadingView?
        
    func loadFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        self.feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewModel(feed: feed))
            }
            self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
