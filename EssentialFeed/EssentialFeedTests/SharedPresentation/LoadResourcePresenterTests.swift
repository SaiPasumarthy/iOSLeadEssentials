//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 23/10/23.
//

import XCTest
import EssentialFeed

final class LoadResourcePresenterTests: XCTestCase {
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none), .display(isLoading: true)])
    }
    
    func test_didFinishLoadingResource_displaysResourceAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resouce in
            resouce + " view model"
        })
        
        sut.didFinishLoading(with: "resource")
        
        XCTAssertEqual(
            view.messages,
            [
                .display(resouceViewModel: "resource view model"),
                .display(isLoading: false)
            ])
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingFeed(with: anyNSError())
        
        XCTAssertEqual(view.messages, [.display(errorMessage: localise("FEED_VIEW_CONNECTION_ERROR")), .display(isLoading: false)])
    }
    
    // MARK: - Helpers
    
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #filePath,
        line: UInt = #line) -> (sut: SUT, view: ViewSpy) {
        let view = ViewSpy()
        let sut = SUT(resourceView: view, loadingView: view, feedErrorView: view, mapper: mapper)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private func localise(_ key: String, file: StaticString = #filePath, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        if value == key {
            XCTFail("Missing localised string for key \(key) in table \(table)", file: file, line: line)
        }
        return value
    }
    
    private class ViewSpy: FeedErrorView, FeedLoadingView, ResourceView {
        typealias ResourceViewModel = String
        enum Message: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool)
            case display(resouceViewModel: String)
        }
        
        var messages: [Message] = []
        
        func display(viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(viewModel: String) {
            messages.append(.display(resouceViewModel: viewModel))
        }
    }
}
