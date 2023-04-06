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
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshViewController = FeedRefreshViewController(feedPresenter: presenter)
        presenter.loadingView = WeakRefVirtualProxy(refreshViewController)
        let feedViewController = FeedViewController(refreshController: refreshViewController)
        presenter.feedView = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        return feedViewController
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
