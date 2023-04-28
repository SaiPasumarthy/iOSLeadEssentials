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
        
        let feedViewController = makeFeedViewController(
            delegate: feedLoaderPresenterAdapter,
            title: FeedPresenter.feedTitle)
        
        let feedAdapter = FeedViewAdapter(controller: feedViewController, loader: MainQueueDispatchDecorator(imageLoader))
        let presenter = FeedPresenter(feedView: feedAdapter, loadingView: WeakRefVirtualProxy(feedViewController), feedErrorView: WeakRefVirtualProxy(feedViewController))
        feedLoaderPresenterAdapter.feedPresenter = presenter
        return feedViewController
    }
}

private func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
    let bundle = Bundle(for: FeedViewController.self)
    let stroyboard = UIStoryboard.init(name: "Feed", bundle: bundle)
    let feedViewController = stroyboard.instantiateInitialViewController() as! FeedViewController
    feedViewController.delegate = delegate
    feedViewController.title = title
    return feedViewController
}

