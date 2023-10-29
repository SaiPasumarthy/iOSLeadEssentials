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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func feedComposedWith(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
                                        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher) -> ListViewController {
        let feedLoaderPresenterAdapter = FeedPresentationAdapter(
            loader: { feedLoader().dispatchOnMainQueue() })
        
        let feedViewController = makeFeedViewController(
            delegate: feedLoaderPresenterAdapter,
            title: FeedPresenter.feedTitle)
        
        let feedAdapter = FeedViewAdapter(controller: feedViewController, loader: { imageLoader($0).dispatchOnMainQueue() })
        
        let presenter = LoadResourcePresenter(
            resourceView: feedAdapter,
            loadingView: WeakRefVirtualProxy(feedViewController),
            errorView: WeakRefVirtualProxy(feedViewController),
            mapper: FeedPresenter.map
        )
        
        feedLoaderPresenterAdapter.presenter = presenter
        return feedViewController
    }
}

private func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let stroyboard = UIStoryboard.init(name: "Feed", bundle: bundle)
    let feedViewController = stroyboard.instantiateInitialViewController() as! ListViewController
    feedViewController.delegate = delegate
    feedViewController.title = title
    return feedViewController
}

