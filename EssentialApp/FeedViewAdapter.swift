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
    private weak var controller: FeedViewController?
    private let imageLoader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.imageLoader = loader
    }
    
    func display(viewModel: FeedViewModel) {
        
        controller?.display(viewModel.feed.map { feedImage in
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(
                loader: { [imageLoader] in
                imageLoader(feedImage.url)
            })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(feedImage),
                delegate: adapter)
            
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    return image
                })
            
            return view
        })
    }
}

private struct InvalidImageData: Error {}
