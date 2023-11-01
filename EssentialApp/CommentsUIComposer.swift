//
//  CommentsUIComposer.swift
//  EssentialApp
//
//  Created by Sai Pasumarthy on 01/11/23.
//

import EssentialFeed
import UIKit
import EssentialFeediOS
import Combine

public final class CommentsUIComposer {
    private init() {}
    
    private typealias CommentsPresentationAdapter = LoadResourcePresentationAdapter<[ImageComment], CommentsViewAdapter>
    
    public static func commentsComposedWith(commentsLoader: @escaping () -> AnyPublisher<[ImageComment], Error>) -> ListViewController {
        let presenterAdapter = CommentsPresentationAdapter(
            loader: { commentsLoader().dispatchOnMainQueue() })
        
        let commentsViewController = makeCommentsViewController(
            title: ImageCommentsPresenter.title)
        commentsViewController.onRefresh = presenterAdapter.loadResource
        
        let commentsAdapter = CommentsViewAdapter(controller: commentsViewController)
        
        let presenter = LoadResourcePresenter(
            resourceView: commentsAdapter,
            loadingView: WeakRefVirtualProxy(commentsViewController),
            errorView: WeakRefVirtualProxy(commentsViewController),
            mapper: { ImageCommentsPresenter.map($0) }
        )
        
        presenterAdapter.presenter = presenter
        return commentsViewController
    }
}

private func makeCommentsViewController(title: String) -> ListViewController {
    let bundle = Bundle(for: ListViewController.self)
    let stroyboard = UIStoryboard.init(name: "ImageComments", bundle: bundle)
    let feedViewController = stroyboard.instantiateInitialViewController() as! ListViewController
    feedViewController.title = title
    return feedViewController
}

final class CommentsViewAdapter: ResourceView {
    private weak var controller: ListViewController?
        
    init(controller: ListViewController) {
        self.controller = controller
    }
    
    func display(viewModel: ImageCommentsViewModel) {
        controller?.display(viewModel.comments.map { viewModel in
            CellControler(id: viewModel, ImageCommentCellController(model: viewModel))
        })
    }
}
