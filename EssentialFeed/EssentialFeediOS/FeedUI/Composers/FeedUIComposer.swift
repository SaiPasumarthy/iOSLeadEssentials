//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 30/03/23.
//

import EssentialFeed
import UIKit

public final class FeedUIComposer {
    private init() {}
    
    static public func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter()
        let feedLoaderPresenterAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, feedPresenter: presenter)
        let refreshViewController = FeedRefreshViewController(delegate: feedLoaderPresenterAdapter)
        presenter.loadingView = WeakRefVirtualProxy(refreshViewController)
        let feedViewController = FeedViewController(refreshController: refreshViewController)
        presenter.feedView = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        return feedViewController
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    let feedLoader: FeedLoader
    let feedPresenter: FeedPresenter
    init(feedLoader: FeedLoader, feedPresenter: FeedPresenter) {
        self.feedLoader = feedLoader
        self.feedPresenter = feedPresenter
    }
    
    func didRequestFeedRefresh() {
        feedPresenter.didStartLoadingFeed()
        self.feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.feedPresenter.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.feedPresenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}

private final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    let loader: FeedImageDataLoader
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { feedImage in
            let viewModel = FeedImageViewModel(model: feedImage, imageLoader: loader, imageTransformer: UIImage.init)
            return FeedImageCellController(viewModel: viewModel)
        }
    }
}
