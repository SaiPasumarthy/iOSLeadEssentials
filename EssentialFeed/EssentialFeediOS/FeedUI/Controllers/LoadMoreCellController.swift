//
//  LoadMoreCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 01/12/23.
//

import UIKit
import EssentialFeed

public class LoadMoreCellController: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let cell = LoadMoreCell()
    private let callback: () -> Void
    
    public init(callback: @escaping () -> Void) {
        self.callback = callback
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        callback()
    }
}

extension LoadMoreCellController: ResourceLoadingView, ResourceErrorView {
    public func display(viewModel: ResourceLoadingViewModel) {
        cell.isLoading = viewModel.isLoading
    }
    public func display(viewModel: ResourceErrorViewModel) {
        cell.message = viewModel.message
    }
}
