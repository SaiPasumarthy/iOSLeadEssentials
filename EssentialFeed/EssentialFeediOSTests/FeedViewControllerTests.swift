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
        load()
    }
    
    @objc func refresh() {
        load()
    }
    
    private func load() {
        self.loader?.load { _ in
            
        }
    }
}
class FeedViewControllerTests: XCTestCase {

    func test_init_donotLoadFeed() {
        let (_, loader) = makeSUT()
                
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    func test_userInitiatedFeedLoad_loadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        sut.refreshControl?.allTargets.forEach { target in
            sut.refreshControl?.actions(forTarget: target,
                                        forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
        
        XCTAssertEqual(loader.loadCount, 2)
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
        
        var loadCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCount += 1
        }
    }

}
