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
    private let selection: (FeedImage) -> Void
    private let currentFeed: [FeedImage: CellControler]
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    private typealias LoadMorePresentationAdapter = LoadResourcePresentationAdapter<Paginated<FeedImage>, FeedViewAdapter>
    
    init(
        currentFeed: [FeedImage: CellControler] = [:],
        controller: ListViewController,
        loader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void
    ) {
        self.currentFeed = currentFeed
        self.controller = controller
        self.imageLoader = loader
        self.selection = selection
    }
    
    func display(viewModel: Paginated<FeedImage>) {
        guard let controller = controller else { return }
        
        var currentFeed = currentFeed
        let feedSection: [CellControler] = viewModel.items.map { feedImage in
            if let controller = currentFeed[feedImage] {
                return controller
            }
            
            let adapter = ImageDataPresentationAdapter(
                loader: { [imageLoader] in
                    imageLoader(feedImage.url)
                })
            
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(feedImage),
                delegate: adapter,
                selection: { [selection] in
                    selection(feedImage)
                }
            )
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            let controller = CellControler(id: feedImage, view)
            currentFeed[feedImage] = controller
            
            return controller
        }
        
        guard let loadMorePublisher = viewModel.loadMorePublisher else {
            controller.display(feedSection)
            return
        }
        
        let loadMoreAdapter = LoadMorePresentationAdapter(loader: loadMorePublisher)
        let loadMore = LoadMoreCellController(callback: loadMoreAdapter.loadResource)

        loadMoreAdapter.presenter = LoadResourcePresenter(
            resourceView: FeedViewAdapter(currentFeed: currentFeed, controller: controller, loader: imageLoader, selection: selection),
            loadingView: WeakRefVirtualProxy(loadMore),
            errorView: WeakRefVirtualProxy(loadMore),
            mapper: { $0 })
        
        let loadMoreSection = [CellControler(id: UUID(), loadMore)]
        
        controller.display(feedSection, loadMoreSection)
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
