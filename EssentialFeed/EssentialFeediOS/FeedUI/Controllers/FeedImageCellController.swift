//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit

final class FeedImageCellController {
    private var viewModel: FeedImageViewModel<UIImage>
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    func view() -> UITableViewCell {
        let feedImageCell = binded(FeedImageCell())
        viewModel.loadImageData()
        return feedImageCell
    }
    func binded(_ view: FeedImageCell) -> FeedImageCell {
        view.locationContainer.isHidden = !viewModel.hasLocation
        view.locationLabel.text = viewModel.location
        view.descriptionLabel.text = viewModel.description
        view.onRetry = viewModel.loadImageData
        viewModel.onImageLoad = { [weak view] image in
            view?.feedImage.image = image
        }
        viewModel.onImageLodingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.imageContainer.startShimmering()
            } else {
                view?.imageContainer.stopShimmering()
            }
        }
        viewModel.onShouldRetryImageLoadStateChange = { [weak view] shouldRetry in
            view?.feedImageRetryButton.isHidden = !shouldRetry
        }
        return view
    }
    func preload() {
        viewModel.loadImageData()
    }
    func cancelLoad() {
        viewModel.cancelImageLoadData()
    }
}
