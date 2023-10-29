//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 15/04/23.
//

import Foundation
import EssentialFeed
import UIKit
import EssentialFeediOS

final class FeedViewAdapter: ResourceView {
    private weak var controller: ListViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = loader
    }
    
    func display(viewModel: FeedViewModel) {
        
        controller?.display(viewModel.feed.map { feedImage in
            let adapter = ImageDataPresentationAdapter(
                loader: { [imageLoader] in
                imageLoader(feedImage.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(feedImage),
                delegate: adapter)
            
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            return view
        })
    }
}

extension UIImage {
    private struct InvalidImageData: Error {}

    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        return image
    }
}
