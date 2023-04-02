//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 02/04/23.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    private var task: FeedImageDataLoaderTask?
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private let imageTrasformer: (Data) -> Image?
    init(model: FeedImage, imageLoader: FeedImageDataLoader, imageTransformer: @escaping (Data) -> Image?) {
        self.model = model
        self.imageLoader = imageLoader
        self.imageTrasformer = imageTransformer
    }
    
    var hasLocation: Bool {
        return model.location != nil
    }
    var location: String? {
        return model.location
    }
    var description: String? {
        return model.description
    }
    
    var onImageLoad: Observer<Image>?
    var onImageLodingStateChange: Observer<Bool>?
    var onShouldRetryImageLoadStateChange: Observer<Bool>?
    
    func loadImageData() {
        onImageLodingStateChange?(true)
        self.onShouldRetryImageLoadStateChange?(false)
        self.task = self.imageLoader.loadImageData(from: self.model.url) { [weak self] result in
            self?.handle(result)
        }
    }
    
    func cancelImageLoadData() {
        task?.cancel()
    }
    
    private func handle(_ result: FeedImageDataLoader.Result) {
        if let image = (try? result.get()).flatMap(imageTrasformer) {
            self.onImageLoad?(image)
        } else {
            self.onShouldRetryImageLoadStateChange?(true)
        }
        self.onImageLodingStateChange?(false)
    }
}
