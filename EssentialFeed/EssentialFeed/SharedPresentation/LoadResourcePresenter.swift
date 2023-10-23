//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 23/10/23.
//

import Foundation

public protocol ResourceView {
    func display(viewModel: String)
}

public final class LoadResourcePresenter {
    public typealias Mapper = (String) -> String
    private let resourceView: ResourceView
    private let feedErrorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let mapper: Mapper
    
    public init(resourceView: ResourceView, loadingView: FeedLoadingView, feedErrorView: FeedErrorView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.feedErrorView = feedErrorView
        self.mapper = mapper
    }

    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoading() {
        feedErrorView.display(viewModel: FeedErrorViewModel.noError)
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: String) {
        resourceView.display(viewModel: mapper(resource))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        feedErrorView.display(viewModel: FeedErrorViewModel.error(message: feedLoadError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
