//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 23/10/23.
//

import XCTest
import EssentialFeed

final class FeedImagePresenterTests: XCTestCase {

    func test_map_createsViewModel() {
        let image = uniqueImage()
        
        let viewModel = FeedImagePresenter<ViewSpy, AnyImage>.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }

    private struct AnyImage: Equatable {}
    private struct ViewSpy: FeedImageView {
        func display(_ model: EssentialFeed.FeedImageViewModel<FeedImagePresenterTests.AnyImage>) {
        }        
    }
}
