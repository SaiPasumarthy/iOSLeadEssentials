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
        let feedLoaderPresenterAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(feedLoader))
        
        let feedViewController = FeedViewController.makeWith(
            delegate: feedLoaderPresenterAdapter,
            title: FeedPresenter.feedTitle)
        
        let feedAdapter = FeedViewAdapter(controller: feedViewController, loader: imageLoader)
        let presenter = FeedPresenter(feedView: feedAdapter, loadingView: WeakRefVirtualProxy(feedViewController))
        feedLoaderPresenterAdapter.feedPresenter = presenter
        return feedViewController
    }
}

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    init(_ feedLoader: T) {
        self.decoratee = feedLoader
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async {
                completion()
            }
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        self.decoratee.load { [weak self ] result in
            self?.dispatch {
                completion(result)
            }
        }
    }
}

private extension FeedViewController {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let stroyboard = UIStoryboard.init(name: "Feed", bundle: bundle)
        let feedViewController = stroyboard.instantiateInitialViewController() as! FeedViewController
        feedViewController.delegate = delegate
        feedViewController.title = title
        return feedViewController
    }
}

private final class FeedImageLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let imageLoader: FeedImageDataLoader
    private let feed: FeedImage
    private var task: FeedImageDataLoaderTask?
    var presenter: FeedImagePresenter<View, Image>?
    init(imageLoader: FeedImageDataLoader, feed: FeedImage) {
        self.imageLoader = imageLoader
        self.feed = feed
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: feed)
        let model = self.feed
        task = imageLoader.loadImageData(from: feed.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelRequestImage() {
        task?.cancel()
    }
}
private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    let feedLoader: FeedLoader
    var feedPresenter: FeedPresenter?
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        feedPresenter?.didStartLoadingFeed()
        self.feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.feedPresenter?.didFinishLoadingFeed(with: feed)
            case let .failure(error):
                self?.feedPresenter?.didFinishLoadingFeed(with: error)
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        self.object?.display(model)
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
            let adapter = FeedImageLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(imageLoader: loader, feed: feedImage)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        }
    }
}
