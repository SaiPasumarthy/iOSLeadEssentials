//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Pasumarthy on 23/03/23.
//

import XCTest
import EssentialFeed

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        refreshControl?.beginRefreshing()
        load()
    }
    
    @objc func refresh() {
        load()
    }
    
    private func load() {
        self.loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
class FeedViewControllerTests: XCTestCase {

    func test_init_donotLoadFeed() {
        let (_, loader) = makeSUT()
                
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_userInitiatedFeedLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedLoad()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_viewDidLoad_showLoadingIndicator() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_viewDidLoad_hideLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_userInitiatedFeedLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.simulateUserInitiatedFeedLoad()
        
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
    }
    
    func test_userInitiatedFeedLoad_hideLoadingIndicatorOnLoaderCompletion() {
        let (sut, loader) = makeSUT()

        sut.simulateUserInitiatedFeedLoad()
        loader.completeFeedLoading()

        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    //MARK: Helpers
    
    func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedViewController, loader: FeedLoaderSpy) {
        let loader = FeedLoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    class FeedLoaderSpy: FeedLoader {
        private var completions: [(FeedLoader.Result) -> Void] = []
        var loadCallCount: Int { return completions.count }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading() {
            completions[0](.success([]))
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
