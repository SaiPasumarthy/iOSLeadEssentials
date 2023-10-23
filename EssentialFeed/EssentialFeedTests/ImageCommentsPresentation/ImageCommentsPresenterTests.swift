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
    
    func test_map_createViewModels() {
        let now = Date()
        let calendar = Calendar(identifier: .gregorian)
        let locale = Locale(identifier: "en_US_POSIX")
        let comments = [
            ImageComment(id: UUID(), message: "a message", createdAt: now.adding(minutes: -5), username: "a username"),
            ImageComment(id: UUID(), message: "another message", createdAt: now.adding(days: -1), username: "another username")
        ]
        
        let viewModel = ImageCommentsPresenter.map(
            comments,
            currentDate: now,
            calendar: calendar,
            locale: locale
        )
        
        XCTAssertEqual(viewModel.comments, [
            ImageCommentViewModel(message: "a message", date: "5 minutes ago", username: "a username"),
            ImageCommentViewModel(message: "another message", date: "1 day ago", username: "another username")
        ])
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
