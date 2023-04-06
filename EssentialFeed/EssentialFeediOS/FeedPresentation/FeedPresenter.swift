//
//  FeedViewPresenter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 06/04/23.
//

import Foundation
import EssentialFeed
protocol FeedLoadingView: AnyObject {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    private var feedLoader: FeedLoader?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedView?
    weak var loadingView: FeedLoadingView?
        
    func loadFeed() {
        loadingView?.display(isLoading: true)
        self.feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.loadingView?.display(isLoading: false)
        }
    }
}
