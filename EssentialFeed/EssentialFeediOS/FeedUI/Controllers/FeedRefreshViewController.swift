//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private var loadFeed: () -> Void
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    // https://swiftrocks.com/whats-type-and-self-swift-metatypes
    private(set) lazy var view: UIRefreshControl = loadView()
        
    @objc
    func refresh() {
        loadFeed()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
    
    private func loadView() -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
