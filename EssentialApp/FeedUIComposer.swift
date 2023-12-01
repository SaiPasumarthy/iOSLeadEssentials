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
    
    private typealias FeedPresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<Paginated<FeedImage>, Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void = { _ in }
    ) -> ListViewController {
        let feedLoaderPresenterAdapter = FeedPresentationAdapter(
            loader: { feedLoader().dispatchOnMainQueue() })
        
        let feedViewController = makeFeedViewController(
            title: FeedPresenter.feedTitle)
        feedViewController.onRefresh = feedLoaderPresenterAdapter.loadResource
        
        let feedAdapter = FeedViewAdapter(
            controller: feedViewController,
            loader: { imageLoader($0).dispatchOnMainQueue() },
            selection: selection
        )
        
        let presenter = LoadResourcePresenter(
            resourceView: feedAdapter,
            loadingView: WeakRefVirtualProxy(feedViewController),
            errorView: WeakRefVirtualProxy(feedViewController),
            mapper: { $0 }
        )
        
        feedLoaderPresenterAdapter.presenter = presenter
        return feedViewController
    }
}

private func makeFeedViewController(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let stroyboard = UIStoryboard.init(name: "Feed", bundle: bundle)
    let feedViewController = stroyboard.instantiateInitialViewController() as! ListViewController
    feedViewController.title = title
    return feedViewController
}

