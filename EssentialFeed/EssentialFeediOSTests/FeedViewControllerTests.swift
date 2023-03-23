//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Pasumarthy on 23/03/23.
//

import XCTest
class FeedViewController {
    
    init(loader: FeedViewControllerTests.FeedLoaderSpy) {
        
    }
}
class FeedViewControllerTests: XCTestCase {

    func test_init_donotLoadFeed() {
        let loader = FeedLoaderSpy()
        
        let _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    //MARK: Helpers
    
    class FeedLoaderSpy {
        var loadCount = 0
        
    }

}
