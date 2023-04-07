//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelRequestImage()
}

final class FeedImageCellController: FeedImageView {
    private var delegate: FeedImageCellControllerDelegate
    private lazy var cell = FeedImageCell()
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    func display(_ model: FeedImageViewModel<UIImage>) {
        cell.locationContainer.isHidden = !model.hasLocation
        cell.locationLabel.text = model.location
        cell.descriptionLabel.text = model.description
        cell.onRetry = delegate.didRequestImage
        cell.feedImage.image = model.image
        if model.isLoading {
            cell.imageContainer.startShimmering()
        } else {
            cell.imageContainer.stopShimmering()
        }
        cell.feedImageRetryButton.isHidden = !model.shouldRetry
    }
    func preload() {
        delegate.didRequestImage()
    }
    func cancelLoad() {
        delegate.didCancelRequestImage()
    }
}
