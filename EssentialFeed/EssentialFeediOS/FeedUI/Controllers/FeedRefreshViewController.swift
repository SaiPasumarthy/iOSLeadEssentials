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
    var delegate: FeedRefreshViewControllerDelegate?
    
    // https://swiftrocks.com/whats-type-and-self-swift-metatypes
    @IBOutlet private var view: UIRefreshControl?
        
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
