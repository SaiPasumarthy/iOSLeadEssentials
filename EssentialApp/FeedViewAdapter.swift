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
    
    private typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
    
    init(
        controller: ListViewController,
        loader: @escaping (URL) -> FeedImageDataLoader.Publisher,
        selection: @escaping (FeedImage) -> Void
    ) {
        self.controller = controller
        self.imageLoader = loader
        self.selection = selection
    }
    
    func display(viewModel: Paginated<FeedImage>) {
        
        let feedSection: [CellControler] = viewModel.items.map { feedImage in
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
            
            return CellControler(id: feedImage, view)
        }
        
        let loadMore = LoadMoreCellController {
            viewModel.loadMore?({ _ in })
        }
        let loadMoreSection = [CellControler(id: UUID(), loadMore)]
        
        controller?.display(feedSection, loadMoreSection)
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
