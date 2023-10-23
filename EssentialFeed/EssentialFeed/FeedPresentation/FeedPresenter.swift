//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 04/05/23.
//

import Foundation

public protocol FeedView {
    func display(viewModel: FeedViewModel)
}

public final class FeedPresenter {
    private let feedView: FeedView
    private let feedErrorView: ResourceErrorView
    private let loadingView: ResourceLoadingView
    
    public init(feedView: FeedView, loadingView: ResourceLoadingView, feedErrorView: ResourceErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.feedErrorView = feedErrorView
    }
    
    public static var feedTitle: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoadingFeed() {
        feedErrorView.display(viewModel: ResourceErrorViewModel.noError)
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        feedErrorView.display(viewModel: ResourceErrorViewModel.error(message: feedLoadError))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
}
