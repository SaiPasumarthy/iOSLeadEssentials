//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 24/03/23.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    private var tableModel = [FeedImage]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var refreshViewController: FeedRefreshViewController?
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
        refreshViewController = FeedRefreshViewController(feedLoader: feedLoader)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshViewController?.view
        refreshViewController?.onRefresh = { [weak self] feed in
            self?.tableModel = feed
        }
        refreshViewController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = tableModel[indexPath.row]
        let feedImageCell = FeedImageCell()
        feedImageCell.locationContainer.isHidden = model.location == nil
        feedImageCell.locationLabel.text = model.location
        feedImageCell.descriptionLabel.text = model.description
        feedImageCell.feedImage.image = nil
        feedImageCell.imageContainer.startShimmering()
        feedImageCell.feedImageRetryButton.isHidden = true
        
        let loadImage = { [weak self, weak feedImageCell] in
            guard let self = self else { return }
            
            self.tasks[indexPath] = self.imageLoader?.loadImageData(from: model.url) { [weak feedImageCell] result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                feedImageCell?.feedImage.image = image
                feedImageCell?.feedImageRetryButton.isHidden = (image != nil)
                feedImageCell?.imageContainer.stopShimmering()
            }
        }
        
        feedImageCell.onRetry = loadImage
        loadImage()
        return feedImageCell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            let model = tableModel[indexPath.row]
            tasks[indexPath] = imageLoader?.loadImageData(from: model.url) { _ in }
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach(cancelTask)
    }
    private func cancelTask(forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}
