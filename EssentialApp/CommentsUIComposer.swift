//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Sai Pasumarthy on 01/11/23.
//

import EssentialFeed
import UIKit
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    private init() {}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[FeedImage], FeedViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) -> ListViewController {
        let presenterAdapter = CommentsPresentationAdapter(
            loader: { commentsLoader().dispatchOnMainQueue() })
        
        let feedViewController = makeFeedViewController(
            title: FeedPresenter.feedTitle)
        feedViewController.onRefresh = presenterAdapter.loadResource
        
        let feedAdapter = FeedViewAdapter(
            controller: feedViewController,
            loader: { _ in Empty<Data, Error>().eraseToAnyPublisher() }
        )
        
        let presenter = LoadResourcePresenter(
            resourceView: feedAdapter,
            loadingView: WeakRefVirtualProxy(feedViewController),
            errorView: WeakRefVirtualProxy(feedViewController),
            mapper: FeedPresenter.map
        )
        
        presenterAdapter.presenter = presenter
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
