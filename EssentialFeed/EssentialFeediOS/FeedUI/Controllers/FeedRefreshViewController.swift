//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewController: NSObject {
    private var feedLoader: FeedLoader?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    // https://swiftrocks.com/whats-type-and-self-swift-metatypes
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    var onRefresh: (([FeedImage]) -> Void)?
    
    @objc
    func refresh() {
        view.beginRefreshing()
        self.feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
