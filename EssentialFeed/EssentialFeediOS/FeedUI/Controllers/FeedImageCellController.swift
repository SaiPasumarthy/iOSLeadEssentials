//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelRequestImage()
}

public final class FeedImageCellController: CellControler, ResourceView, ResourceLoadingView, ResourceErrorView {
    public typealias ResourceViewModel = UIImage
    private var delegate: FeedImageCellControllerDelegate
    private var viewModel: FeedImageViewModel
    private var cell: FeedImageCell?
    public init(viewModel: FeedImageViewModel, delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
        self.viewModel = viewModel
    }
    public func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        cell?.locationContainer.isHidden = !viewModel.hasLocation
        cell?.locationLabel.text = viewModel.location
        cell?.descriptionLabel.text = viewModel.description
        cell?.onRetry = delegate.didRequestImage
        delegate.didRequestImage()
        return cell!
    }
    public func preload() {
        delegate.didRequestImage()
    }
    public func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelRequestImage()
    }
    private func releaseCellForReuse() {
        cell = nil
    }
    public func display(viewModel: UIImage) {
        cell?.feedImage.setImageAnimated(viewModel)
    }
    public func display(viewModel: ResourceLoadingViewModel) {
        cell?.imageContainer.isShimmering = viewModel.isLoading
    }
    public func display(viewModel: ResourceErrorViewModel) {
        cell?.feedImageRetryButton.isHidden = viewModel.message == nil
    }
}
