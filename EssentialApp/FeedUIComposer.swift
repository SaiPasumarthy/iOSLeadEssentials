//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 30/03/23.
//

import EssentialFeed
import UIKit
import EssentialFeediOS
import Combine

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: @escaping () -> FeedLoader.Publisher,
                                        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> FeedViewController {
        let feedLoaderPresenterAdapter = FeedLoaderPresentationAdapter(feedLoader: { feedLoader().dispatchOnMainQueue() })
        
        let feedViewController = makeFeedViewController(
            delegate: feedLoaderPresenterAdapter,
            title: FeedPresenter.feedTitle)
        
        let feedAdapter = FeedViewAdapter(controller: feedViewController, loader: { imageLoader($0).dispatchOnMainQueue() })
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

