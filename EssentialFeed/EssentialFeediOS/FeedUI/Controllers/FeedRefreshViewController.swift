//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    private var feedViewModel: FeedViewModel?
    init(feedViewModel: FeedViewModel) {
        self.feedViewModel = feedViewModel
    }
    // https://swiftrocks.com/whats-type-and-self-swift-metatypes
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
        
    @objc
    func refresh() {
        feedViewModel?.loadFeed()
    }
    
    private func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        feedViewModel?.onLodingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
