//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 24/03/23.
//

import UIKit
import SwiftUI
import EssentialFeed
import Combine
struct FeedViewUI: View {
    @State var tableModel = [FeedImage]()
    private var model: FeedViewModel?
    private var imageView: (FeedImage) -> FeedImageCellView
    init(model: FeedViewModel, imageView: @escaping (FeedImage) -> FeedImageCellView) {
        self.model = model
        self.imageView = imageView
    }
    var body: some View {
        Text("")
        imageView(FeedImage(id: UUID(), description: nil, location: nil, url: URL(string: "")!))
    }
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var tableModel = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    private var refreshViewController: FeedRefreshViewController?
    convenience init(refreshController: FeedRefreshViewController) {
        self.init()
        refreshViewController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        tableView.prefetchDataSource = self
        refreshControl = refreshViewController?.view
        refreshViewController?.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellController = cellController(forRowAt: indexPath)
        return cellController.view()
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
