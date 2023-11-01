//
//  CommentsUIIntegrationTests.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 01/11/23.
//

import XCTest
import UIKit
import EssentialApp
import EssentialFeed
import EssentialFeediOS
import Combine

final class CommentsUIIntegrationTests: XCTestCase {
    func test_commentsView_hasTitle() {
        let (sut, _) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.title, commentsTitle)
    }
    
    func test_loadCommentsActions_requestCommentsFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(loader.loadCommentsCallCount, 0)

        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCommentsCallCount, 1)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 2)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(loader.loadCommentsCallCount, 3)
    }
        
    func test_loadingCommentsIndicator_isVisibleWhileLoadingComments() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeCommentsLoading(at: 0)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.isShowingLoadingIndicator, true)
        
        loader.completeCommentsLoadingWithError(at: 1)
        XCTAssertEqual(sut.isShowingLoadingIndicator, false)
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedComments() {
        let comment0 = makeComment(message: "a message", username: "a username")
        let comment1 = makeComment(message: "another message", username: "another username")
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        assertThat(sut, isRendering: [])
        
        loader.completeCommentsLoading(with: [comment0], at: 0)
        assertThat(sut, isRendering: [comment0])
                
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [comment0, comment1], at: 1)
        assertThat(sut, isRendering: [comment0, comment1])
    }
    
    func test_loadCommentsCompletion_rendersSuccessfullyLoadedEmptyCommentsAfterNonEmptyComments() {
        let comment = makeComment()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeCommentsLoading(with: [comment], at: 0)
        assertThat(sut, isRendering: [comment])
                
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoading(with: [], at: 1)
        assertThat(sut, isRendering: [])
    }
    
    func test_loadCommentsCompletion_doesnotAlterCurrentRenderingStateOnError() {
        let image0 = makeComment()
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        
        loader.completeCommentsLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedReload()
        loader.completeCommentsLoadingWithError(at: 0)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_loadCommentsCompletion_dispatchesFromBackgroundToMainThread() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        let exp = expectation(description: "Wait for background queue")
        
        DispatchQueue.global().async {
            loader.completeCommentsLoading(at: 0)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCommentsCompletion_rendersErrorMessageOnErrorUntilNextReload() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateUserInitiatedReload()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    func test_tapOnErrorView_hidesErrorMessage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.errorMessage, nil)
        
        loader.completeCommentsLoadingWithError(at: 0)
        XCTAssertEqual(sut.errorMessage, loadError)
        
        sut.simulateErrorViewTap()
        XCTAssertEqual(sut.errorMessage, nil)
    }
    
    //MARK: Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ListViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = CommentsUIComposer.commentsComposedWith(commentsLoader: loader.loadPublisher)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    func assertThat(_ sut: ListViewController, isRendering comments: [ImageComment],
                    file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedComments() == comments.count else {
            XCTFail("Feed Image cell count didn't match", file: file, line: line)
            return
        }
        let viewModel = ImageCommentsPresenter.map(comments)
        
        viewModel.comments.enumerated().forEach { index, comment in
            XCTAssertEqual(sut.commentMessage(at: index), comment.message, file: file, line: line)
            XCTAssertEqual(sut.commentDate(at: index), comment.date, file: file, line: line)
            XCTAssertEqual(sut.commentUsername(at: index), comment.username, file: file, line: line)
        }
    }
    func makeComment(message: String = "any message", username: String = "any username") -> ImageComment {
        return ImageComment(id: UUID(), message: message, createdAt: Date(), username: username)
    }

    private class LoaderSpy {
        private var requests: [PassthroughSubject<[ImageComment], Error>] = []
        
        var loadCommentsCallCount: Int { return requests.count }
        
        func loadPublisher() -> AnyPublisher<[ImageComment], Error> {
            let publisher = PassthroughSubject<[ImageComment], Error>()
            requests.append(publisher)
            
            return publisher.eraseToAnyPublisher()
        }
        
        func completeCommentsLoading(with feed: [ImageComment] = [], at index: Int) {
            requests[index].send(feed)
        }
        
        func completeCommentsLoadingWithError(at index: Int) {
            let anyError = NSError(domain: "any error", code: 0)
            requests[index].send(completion: .failure(anyError))
        }
    }
}
