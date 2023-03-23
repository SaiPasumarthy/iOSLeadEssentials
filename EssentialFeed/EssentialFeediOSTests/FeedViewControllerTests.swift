//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Pasumarthy on 23/03/23.
//

import XCTest
import EssentialFeed

class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        self.loader?.load { _ in
            
        }
    }
}
class FeedViewControllerTests: XCTestCase {

    func test_init_donotLoadFeed() {
        let loader = FeedLoaderSpy()
        
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_viewDidLoad_loadsFeed() {
        let loader = FeedLoaderSpy()

        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    //MARK: Helpers
    
    class FeedLoaderSpy: FeedLoader {
        
        var loadCount = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCount += 1
        }
    }

}
