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

final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    init(controller: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { feedImage in
            let adapter = FeedImageLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellController>, UIImage>(imageLoader: loader, feed: feedImage)
            let view = FeedImageCellController(delegate: adapter)
            adapter.presenter = FeedImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
            return view
        })
    }
}
