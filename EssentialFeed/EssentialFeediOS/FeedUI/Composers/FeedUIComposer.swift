//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 30/03/23.
//

import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    static public func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let refreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshViewController)
        refreshViewController.onRefresh = { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map { feedImage in
                FeedImageCellController(model: feedImage, imageLoader: imageLoader)
            }
        }
        return feedViewController
    }
}
