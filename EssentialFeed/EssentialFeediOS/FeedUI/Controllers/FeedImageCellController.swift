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

public final class FeedImageCellController: FeedImageView {
    private var delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    func view(in tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    public func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !model.hasLocation
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.onRetry = delegate.didRequestImage
        cell?.feedImage.setImageAnimated(model.image)
        if model.isLoading {
            cell?.imageContainer.startShimmering()
        } else {
            cell?.imageContainer.stopShimmering()
        }
        cell?.feedImageRetryButton.isHidden = !model.shouldRetry
    }
    func preload() {
        delegate.didRequestImage()
    }
    func cancelLoad() {
        releaseCellForReuse()
        delegate.didCancelRequestImage()
    }
    private func releaseCellForReuse() {
        cell = nil
    }
}
