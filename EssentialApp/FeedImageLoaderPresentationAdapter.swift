//
//  FeedImageLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 15/04/23.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedImageLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let imageLoader: FeedImageDataLoader
    private let feed: FeedImage
    private var task: FeedImageDataLoaderTask?
    var presenter: FeedImagePresenter<View, Image>?
    init(imageLoader: FeedImageDataLoader, feed: FeedImage) {
        self.imageLoader = imageLoader
        self.feed = feed
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: feed)
        let model = self.feed
        task = imageLoader.loadImageData(from: feed.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelRequestImage() {
        task?.cancel()
    }
}
