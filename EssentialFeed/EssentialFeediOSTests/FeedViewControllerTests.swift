//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Pasumarthy on 23/03/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
        
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeFeedLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
        
        sut.simulateUserInitiatedFeedLoad()
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
        
        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        assertThat(sut, isRendering: [image0, image1])
        
        sut.simulateUserInitiatedFeedLoad()
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        assertThat(sut, isRendering: [image0, image1, image2, image3])
    }
    
    func test_loadFeedCompletion_doesnotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage(description: "a description", location: "a location")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedLoad()
        loader.completeFeedLoadingWithError(at: 0)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadsImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "https://any-image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://any-image-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.loadedImageURLs, [])
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url])
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url])
    }
    
    func test_feedImageView_cacelImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "https://any-image-url.com")!)
        let image1 = makeImage(url: URL(string: "https://any-image-url-2.com")!)
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)

        XCTAssertEqual(loader.cancelledImageURLs, [])
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url])
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url])
    }
    
    //MARK: Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    func assertThat(_ sut: FeedViewController, isRendering feed: [FeedImage],
                    file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedFeedImageViews() == feed.count else {
            XCTFail("Feed Image cell count didn't match", file: file, line: line)
            return
        }
        feed.enumerated().forEach { index, image in
            assertThat(sut, hasViewConfiguredFor: image, at: index)
        }
    }
    func assertThat(_ sut: FeedViewController, hasViewConfiguredFor image: FeedImage, at index: Int,
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
    class FeedLoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        private var completions: [(FeedLoader.Result) -> Void] = []
        var loadCallCount: Int { return completions.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage] = [], at index: Int) {
            completions[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let anyError = NSError(domain: "any error", code: 0)
            completions[index](.failure(anyError))
        }
        
        // MARK: - FeedImageDataLoader
        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()

        private struct TaskSpy: FeedImageDataLoaderTask {
            let cacelCallBack: () -> Void
            func cancel() {
                cacelCallBack()
            }
        }
        
        func loadImageData(from url: URL) -> FeedImageDataLoaderTask {
            loadedImageURLs.append(url)
            return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
        }
    }
}

private extension FeedViewController {
    func simulateUserInitiatedFeedLoad() {
        refreshControl?.simulatePullRefresh()
    }
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        return self.tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        let ds = tableView.dataSource
        let index = IndexPath(row: index, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at index: Int) {
        let feedImageCell = feedImageView(at: index)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: index, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: feedImageCell!, forRowAt: index)
    }
}
private extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    var locationText: String? {
        return locationLabel.text
    }
    var descriptionText: String? {
        return descriptionLabel.text
    }
}
private extension UIRefreshControl {
    func simulatePullRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target,
                                        forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
