//
//  FeedPresentationTests.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 21/04/23.
//

import XCTest
import EssentialFeed

class FeedPresenterTests: XCTestCase {
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.feedTitle, localise("FEED_VIEW_TITLE"))
    }
    
    func test_map_createsViewModel() {
        let feed = uniqueImageFeed().models
        
        let viewModel = FeedPresenter.map(feed)
        
        XCTAssertEqual(viewModel.feed, feed)
    }
    
    private func localise(_ key: String, table: String = "Feed", file: StaticString = #filePath, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localised string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
}
