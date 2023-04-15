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
        
        let feedAdapter = FeedViewAdapter(controller: feedViewController, loader: MainQueueDispatchDecorator(imageLoader))
        let presenter = FeedPresenter(feedView: feedAdapter, loadingView: WeakRefVirtualProxy(feedViewController))
        feedLoaderPresenterAdapter.feedPresenter = presenter
        return feedViewController
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

final class FeedImageLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
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
final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
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
