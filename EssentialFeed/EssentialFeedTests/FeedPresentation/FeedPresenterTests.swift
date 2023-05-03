//
//  FeedPresentationTests.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 21/04/23.
//

import XCTest
struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
}
protocol FeedErrorView {
    func display(viewModel: FeedErrorViewModel)
}
class FeedPresenter {
    private let feedErrorView: FeedErrorView
    
    init(feedErrorView: FeedErrorView) {
        self.feedErrorView = feedErrorView
    }
    
    func didStartLoadingFeed() {
        feedErrorView.display(viewModel: FeedErrorViewModel.noError)
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessageToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [ViewSpy.Message.display(.none)])
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(feedErrorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
    
    private class ViewSpy: FeedErrorView {
        enum Message: Equatable {
            case display(String?)
        }
        
        var messages: [Message] = []
        
        func display(viewModel: FeedErrorViewModel) {
            messages.append(.display(viewModel.message))
        }
    }
}
