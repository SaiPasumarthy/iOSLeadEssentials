//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingView {
    private var delegate: FeedRefreshViewControllerDelegate
    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    // https://swiftrocks.com/whats-type-and-self-swift-metatypes
    private(set) lazy var view: UIRefreshControl = loadView()
        
    @objc
    func refresh() {
        delegate.didRequestFeedRefresh()
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
