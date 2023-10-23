//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 23/10/23.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) -> View.ResourceViewModel
    private let resourceView: View
    private let feedErrorView: FeedErrorView
    private let loadingView: FeedLoadingView
    private let mapper: Mapper
    
    public init(resourceView: View, loadingView: FeedLoadingView, feedErrorView: FeedErrorView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.feedErrorView = feedErrorView
        self.mapper = mapper
    }

    public static var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error message displayed when we can't load the resource from the server")
    }
    
    public func didStartLoading() {
        feedErrorView.display(viewModel: FeedErrorViewModel.noError)
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        resourceView.display(viewModel: mapper(resource))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        feedErrorView.display(viewModel: FeedErrorViewModel.error(message: Self.loadError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
