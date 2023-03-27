//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 24/03/23.
//

import UIKit
import EssentialFeed

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageDataLoader {
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

final public class FeedViewController: UITableViewController {
    private var feedLoader: FeedLoader?
    private var imageLoader: FeedImageDataLoader?
    private var tasks = [IndexPath: FeedImageDataLoaderTask]()
    private var tableModel: [FeedImage] = []
    public convenience init(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) {
        self.init()
        self.feedLoader = feedLoader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        load()
    }
    
    @objc func refresh() {
        load()
    }
    
    private func load() {
        refreshControl?.beginRefreshing()
        self.feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
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
        tasks[indexPath] = imageLoader?.loadImageData(from: model.url) { [weak feedImageCell] result in
            let data = try? result.get()
            let image = data.map(UIImage.init) ?? nil
            feedImageCell?.feedImage.image = image
            feedImageCell?.feedImageRetryButton.isHidden = (image != nil)
            feedImageCell?.imageContainer.stopShimmering()
        }
        return feedImageCell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}
