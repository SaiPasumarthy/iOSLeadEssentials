//
//  ImageCommentsPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 23/10/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsPresenterTests: XCTestCase {

    func test_title_isLocalized() {
        XCTAssertEqual(ImageCommentsPresenter.title, localise("IMAGE_COMMENTS_VIEW_TITLE"))
    }
    
    private func localise(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table: String = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localised string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }

}
