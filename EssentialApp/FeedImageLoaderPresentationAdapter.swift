//
//  FeedImageLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 15/04/23.
//

import Combine
import Foundation
import EssentialFeed
import EssentialFeediOS

final class FeedImageLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private var cancellable: Cancellable?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    private let feed: FeedImage
    var presenter: FeedImagePresenter<View, Image>?
    init(imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher, feed: FeedImage) {
        self.imageLoader = imageLoader
        self.feed = feed
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: feed)
        let model = self.feed
        
        cancellable = imageLoader(model.url)
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                    
                case let .failure(error):
                    self?.presenter?.didFinishLoadingImageData(with: error, for: model)
                }
            } receiveValue: { [weak self] data in
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
            }
    }
    
    func didCancelRequestImage() {
        cancellable?.cancel()
    }
}
