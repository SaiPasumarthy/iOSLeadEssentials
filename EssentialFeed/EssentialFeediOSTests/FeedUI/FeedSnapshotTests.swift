//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Pasumarthy on 18/06/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapshotTests: XCTestCase {

    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_CONTENT_light_extraExtraExtraLarge")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light_extraExtraExtraLarge")
    }
    
    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreIndicator())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
    }

    func test_feedWithLoadMoreError() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreError())
        
        assert(snapshot: sut.snapshot(for: .iPhone(style: .dark)), named: "FEED_WITH_LOAD_MORE_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light)), named: "FEED_WITH_LOAD_MORE_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_ERROR_light_extraExtraExtraLarge")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Cannon Street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Brighton Seafront",
                image: nil
            )
        ]
    }
    
    private func feedWithLoadMoreIndicator() -> [CellControler] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(viewModel: ResourceLoadingViewModel(isLoading: true))
        
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWithLoadMoreError() -> [CellControler] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(viewModel: ResourceErrorViewModel(message: "This is multiline\nerror message"))
        
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWith(loadMore: LoadMoreCellController) -> [CellControler] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        stub.controller = cellController
        
        return [
            CellControler(id: UUID(), cellController),
            CellControler(id: UUID(), loadMore)
        ]
    }
}

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellControler] = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
            stub.controller = cellController
            return CellControler(id: UUID(), cellController)
        }
        
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    let image: UIImage?
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(
            description: description,
            location: location
        )
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(viewModel: ResourceLoadingViewModel(isLoading: false))
        if let image = image {
            controller?.display(viewModel: image)
            controller?.display(viewModel: ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(viewModel: ResourceErrorViewModel(message: "any"))
        }
    }
    
    func didCancelRequestImage() {}
}
