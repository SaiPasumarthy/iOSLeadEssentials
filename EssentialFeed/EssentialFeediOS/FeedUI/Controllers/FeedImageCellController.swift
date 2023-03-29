//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/03/23.
//

import UIKit
import EssentialFeed

final class FeedImageCellController {
    private var task: FeedImageDataLoaderTask?
    private var model: FeedImage
    private var imageLoader: FeedImageDataLoader
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    func view() -> UITableViewCell {
        let feedImageCell = FeedImageCell()
        feedImageCell.locationContainer.isHidden = model.location == nil
        feedImageCell.locationLabel.text = model.location
        feedImageCell.descriptionLabel.text = model.description
        feedImageCell.feedImage.image = nil
        feedImageCell.imageContainer.startShimmering()
        feedImageCell.feedImageRetryButton.isHidden = true
        
        let loadImage = { [weak self, weak feedImageCell] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak feedImageCell] result in
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
    func preload() {
        task = imageLoader.loadImageData(from: model.url, completion: { _ in })
    }
    deinit {
        task?.cancel()
    }
}
