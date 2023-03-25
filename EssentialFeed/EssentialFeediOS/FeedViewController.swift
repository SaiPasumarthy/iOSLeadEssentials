//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 24/03/23.
//

import UIKit
import EssentialFeed

final public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var tableModel: [FeedImage] = []
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
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
        self.loader?.load { [weak self] result in
            self?.refreshControl?.endRefreshing()
            self?.tableModel = (try? result.get()) ?? []
            self?.tableView.reloadData()
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
        return feedImageCell
    }
}
