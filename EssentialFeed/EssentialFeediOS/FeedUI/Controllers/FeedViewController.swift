//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 24/03/23.
//

import UIKit
import EssentialFeed

protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, FeedLoadingView, FeedErrorView {
    @IBOutlet private(set) public var errorView: ErrorView?
    
    private var cellControllers = [IndexPath: FeedImageCellController]()
    var delegate: FeedViewControllerDelegate?
    
    var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    public func display(viewModel: FeedLoadingViewModel) {
        refreshControl?.update(isRefreshing: viewModel.isLoading)
    }
    
    public func display(viewModel: FeedErrorViewModel) {
        errorView?.show(message: viewModel.message)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        removeCellController(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let cellController = cellController(forRowAt: indexPath)
            cellController.preload()
        }
    }
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(removeCellController)
    }
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    private func removeCellController(forRowAt indexPath: IndexPath) {
        tableModel[indexPath.row].cancelLoad()
    }
}