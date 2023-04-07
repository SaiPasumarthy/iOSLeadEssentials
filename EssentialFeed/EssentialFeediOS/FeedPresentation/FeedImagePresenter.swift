//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 06/04/23.
//

import Foundation
import EssentialFeed

protocol FeedImageView {
    associatedtype Image
    func display(_ model: FeedImageViewModel<Image>)
}

final class FeedImagePresenter<View: FeedImageView, Image> where View.Image == Image {
    private let imageTrasformer: (Data) -> Image?
    private let view: View
    init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTrasformer = imageTransformer
    }
    
    func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModel(description: model.description, location: model.location, image: nil, isLoading: true, shouldRetry: false))
    }
    
    private struct InvalidImageDataError: Error {}
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        guard let image = imageTrasformer(data) else {
            return didFinishLoadingImageData(with: InvalidImageDataError(), for: model)
        }
        
        view.display(FeedImageViewModel(description: model.description, location: model.location, image: image, isLoading: false, shouldRetry: false))
    }
    
    func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModel(description: model.description, location: model.location, image: nil, isLoading: false, shouldRetry: true))
    }
}
