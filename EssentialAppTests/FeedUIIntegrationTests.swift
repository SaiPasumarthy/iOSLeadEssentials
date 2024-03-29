//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Pasumarthy on 23/03/23.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS

class FeedUIIntegrationTests: XCTestCase {
    func test_feedView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.simulateAppearance()
        
        XCTAssertEqual(sut.title, feedTitle)
    }
    
    func test_imageSelection_notifiesHandler() {
        let image0 = makeImage()
        let image1 = makeImage()
        var selectedImages = [FeedImage]()
        let (sut, loader) = makeSUT(selection: { selectedImages.append($0) })
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
                
        sut.simulateTapOnFeedImage(at: 0)
        XCTAssertEqual(selectedImages, [image0])
        
        sut.simulateTapOnFeedImage(at: 1)
        XCTAssertEqual(selectedImages, [image0, image1])
    }
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)

        sut.simulateAppearance()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        loader.completeFeedLoading(at: 0)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        loader.completeFeedLoading(at: 1)
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
        
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(description: "a description", location: "a location")
        let image1 = makeImage(description: nil, location: "a location")
        let image2 = makeImage(description: "a description", location: nil)
        let image3 = makeImage(description: nil, location: nil)
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        assertThat(sut, isRendering: [])
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
                
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1, image2, image3], at: 0)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [image0, image1], at: 1)
        assertThat(sut, isRendering: [image0, image1])
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedEmptyFeedAfterNonEmptyFeed() {
        let image0 = makeImage()
        let image1 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
                
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadFeedCompletion_doesnotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeFeedLoadingWithError(at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMoreWithError(at: 0)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadFeedCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeFeedLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_loadMoreCompletion_rendersErrorMessageOnError() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(at: 0)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
        
        loader.completeLoadMoreWithError(at: 0)
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, loadError)
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(sut.loadMoreFeedErrorMessage, nil)
    }
    
    func test_tapOnLoadMoreErrorView_loadsMore() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(at: 0)
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        sut.simulateTapOnLoadMoreFeedError()
        XCTAssertEqual(loader.loadMoreCallCount, 1)

        loader.completeLoadMoreWithError()
        sut.simulateTapOnLoadMoreFeedError()
        XCTAssertEqual(loader.loadMoreCallCount, 2)
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://any-image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://any-image-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://any-image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://any-image-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageViewLoadingIndicator_isVisibileWhileLoadingImage() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoading(at: 0)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.renderedImage, .none)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let image0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(image0, at: 0)
        XCTAssertEqual(view0?.renderedImage, image0)
        XCTAssertEqual(view1?.renderedImage, .none)
        
        let image1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(image1, at: 1)
        XCTAssertEqual(view0?.renderedImage, image0)
        XCTAssertEqual(view1?.renderedImage, image1)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        
        XCTAssertEqual(view0?.isShowRetryAction, false)
        XCTAssertEqual(view1?.isShowRetryAction, false)
        
        let image0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(image0, at: 0)
        XCTAssertEqual(view0?.isShowRetryAction, false)
        XCTAssertEqual(view1?.isShowRetryAction, false)
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(view0?.isShowRetryAction, false)
        XCTAssertEqual(view1?.isShowRetryAction, true)
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()], at: 0)

        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view0?.isShowRetryAction, false)
        
        let invalidImageData = Data("a invalid data".utf8)
        loader.completeImageLoading(invalidImageData, at: 0)
        XCTAssertEqual(view0?.isShowRetryAction, true)
    }
    
    func test_feedImageViewRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "https://any-image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://any-image-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
        
        loader.completeImageLoadingWithError(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])

        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url])
        
        view0?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url])

        loader.completeImageLoading(at: 1)
        view1?.simulateRetryAction()
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url, image0.url, image1.url])
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "https://any-image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://any-image-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.loadedImageURLs, [])

        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])

        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cancelsImageURLPreloadsImageURLWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://any-image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://any-image-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedImageViewNearNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])

        sut.simulateFeedImageViewNearNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])

    }
    
    func test_feedImageView_configuresViewCorrectlyWhenTransitioningFromNearVisibleToVisibleWhileStillPreloadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        
        XCTAssertEqual(view0?.renderedImage, nil, "Expected no rendered image when view becomes visible while still preloading image")
        XCTAssertEqual(view0?.isShowRetryAction, false, "Expected no retry action when view becomes visible while still preloading image")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true, "Expected loading indicator when view becomes visible while still preloading image")
        
        let imageData = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(imageData, at: 0)
        
        XCTAssertEqual(view0?.renderedImage, imageData, "Expected rendered image after image preloads successfully")
        XCTAssertEqual(view0?.isShowRetryAction, false, "Expected no retry action after image preloads successfully")
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false, "Expected no loading indicator after image preloads successfully")
    }
    
    func test_feedImageView_doesnotRenderLoadedImageWhenNotVisibleAnyMore() {
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()], at: 0)

        let view = sut.simulateFeedImageViewNotVisible(at: 0)
        let image0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(image0, at: 0)
        
        XCTAssertNil(view?.renderedImage)
    }
    
    func test_loadFeedCompletion_dispatchsFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        
        let expectation = expectation(description: "Wait for background execution")
        DispatchQueue.global().async {
            loader.completeFeedLoading(at: 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_loadMoreCompletion_dispatchsFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(at: 0)
        sut.simulateLoadMoreFeedAction()
        
        let expectation = expectation(description: "Wait for background execution")
        DispatchQueue.global().async {
            loader.completeLoadMore(at: 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_loadImageDataCompletion_dispatchsFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        let image0 = UIImage.make(withColor: .red).pngData()!

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        _ = sut.simulateFeedImageViewVisible(at: 0)
        
        let expectation = expectation(description: "Wait for background execution")
        DispatchQueue.global().async {
            loader.completeImageLoading(image0, at: 0)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_loadMoreActions_requestLoadMoreFromLoader() {
        let (sut, loader) = makeSUT()
        sut.simulateAppearance()
        loader.completeFeedLoading(at: 0)
        
        XCTAssertEqual(loader.loadMoreCallCount, 0)

        sut.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        sut.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(loader.loadMoreCallCount, 1)
        
        loader.completeLoadMore(lastPage: false, at: 0)
        sut.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(loader.loadMoreCallCount, 2)
        
        loader.completeLoadMoreWithError(at: 1)
        sut.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(loader.loadMoreCallCount, 3)
        
        loader.completeLoadMore(lastPage: true, at: 2)
        sut.simulateLoadMoreFeedAction()
        
        XCTAssertEqual(loader.loadMoreCallCount, 3)
    }
    func test_loadingMoreIndicator_isVisibleWhileLoadingMore() {
        let (sut, loader) = makeSUT()
        
        sut.simulateAppearance()
        XCTAssertEqual(sut.isShowingLoadMoreFeedIndicator, false)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadMoreFeedIndicator, false)
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(sut.isShowingLoadMoreFeedIndicator, true)
        
        loader.completeLoadMore(at: 0)
        XCTAssertEqual(sut.isShowingLoadMoreFeedIndicator, false)
        
        sut.simulateLoadMoreFeedAction()
        XCTAssertEqual(sut.isShowingLoadMoreFeedIndicator, true)
        
        loader.completeLoadMoreWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadMoreFeedIndicator, false)
    }
    
    func test_feedImageView_doesNotLoadImageAgainUntilPreviousRequestCompletes() {
        let image = makeImage(url: URL(string: "https://any-image-url.com")!)
        let (sut, loader) = makeSUT()

        sut.simulateAppearance()
        loader.completeFeedLoading(with: [image], at: 0)
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url])

        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url])
        
        loader.completeImageLoading(at: 0)
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url, image.url])
        
        sut.simulateFeedImageViewNearNotVisible(at: 0)
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url, image.url, image.url])
        
        sut.simulateLoadMoreFeedAction()
        loader.completeLoadMore(with: [image, makeImage()], at: 0)
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image.url, image.url, image.url])
    }
    
    //MARK: Helpers
    
    func makeSUT(
        selection: @escaping (FeedImage) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) -> (sut: ListViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedUIComposer.feedComposedWith(
            feedLoader: loader.loadPublisher,
            imageLoader: loader.loadImageDataPublisher,
            selection: selection
        )
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    func assertThat(_ sut: ListViewController, isRendering feed: [FeedImage],
                    file: StaticString = #filePath, line: UInt = #line) {
        sut.view.enforceLayoutCycle()
        
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            XCTFail("Feed Image cell count didn't match", file: file, line: line)
            return
        }
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index, file: file, line: line)
        }
        executeRunLoopToCleanUpReferences()
    }
    func assertThat(_ sut: ListViewController, hasViewConfiguredFor image: FeedImage, at index: Int,
                    file: StaticString = #filePath, line: UInt = #line) {
        let feedImageCell = sut.feedImageView(at: index) as? FeedImageCell
        guard let feedImageCell = feedImageCell else {
            XCTFail("Feed Image cell is nil", file: file, line: line)
            return
        }
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(feedImageCell.isShowingLocation, shouldLocationBeVisible, file: file, line: line)
        XCTAssertEqual(feedImageCell.locationText, image.location, file: file, line: line)
        XCTAssertEqual(feedImageCell.descriptionText, image.description, file: file, line: line)
    }
    func makeImage(description: String? = nil, location: String? = nil,
                   url: URL = URL(string: "https://any-url.com")!) -> FeedImage {
        return FeedImage(id: UUID(), description: description, location: location, url: url)
    }
    private func executeRunLoopToCleanUpReferences() {
        RunLoop.current.run(until: Date())
    }
}
