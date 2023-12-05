//
//  FeedViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import EssentialFeediOS
import UIKit

extension ListViewController {
    func simulateAppearance() {
        if !isViewLoaded {
            loadViewIfNeeded()
            prepareForFirstAppearance()
        }

        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
    
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullRefresh()
    }
    
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var errorMessage: String? {
        return errorView.errorMessage
    }
    
    func numberOfRows(in section: Int) -> Int {
        tableView.numberOfSections > section ? tableView.numberOfRows(inSection: section) : 0
    }
    
    func cell(row: Int, section: Int) -> UITableViewCell? {
        guard numberOfRows(in: section) > row else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: row, section: section)
        return ds?.tableView(tableView, cellForRowAt: index)
    }
}

extension ListViewController {
    func numberOfRenderedComments() -> Int {
        numberOfRows(in: commentsSection)
    }
    
    private var commentsSection: Int { 0 }
    
    func commentMessage(at index: Int) -> String? {
        commentsView(at: index)?.messageLabel.text
    }
    
    func commentDate(at index: Int) -> String? {
        commentsView(at: index)?.dateLabel.text
    }
    
    func commentUsername(at index: Int) -> String? {
        commentsView(at: index)?.usernameLabel.text
    }
    
    private func commentsView(at row: Int) -> ImageCommentCell? {
        cell(row: row, section: commentsSection) as? ImageCommentCell
    }
    
    private func prepareForFirstAppearance() {
        setSmallFrameToPreventRenderingCells()
        replaceRefreshControlWithSpyForiOS17Support()
    }
    
    private func setSmallFrameToPreventRenderingCells() {
        tableView.frame = CGRect(x: 0, y: 0, width: 390, height: 1)
    }

    private func replaceRefreshControlWithSpyForiOS17Support() {
        let spyRefreshControl = UIRefreshControlSpy()

        refreshControl?.allTargets.forEach { target in
            refreshControl?.actions(forTarget: target, forControlEvent: .valueChanged)?.forEach { action in
                spyRefreshControl.addTarget(target, action: Selector(action), for: .valueChanged)
            }
        }

        refreshControl = spyRefreshControl
    }
}

extension ListViewController {
    func numberOfRenderedFeedImageViews() -> Int {
        numberOfRows(in: feedImageSection)
    }
    
    private var feedImageSection: Int { 0 }
    private var loadMoreSection: Int { 1 }
    
    func simulateTapOnFeedImage(at row: Int) {
        let delegate = tableView.delegate
        let index = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didSelectRowAt: index)
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        cell(row: index, section: feedImageSection)
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at index: Int) -> FeedImageCell? {
        let feedImageCell = simulateFeedImageViewVisible(at: index)
        
        let delegate = tableView.delegate
        let index = IndexPath(row: index, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: feedImageCell!, forRowAt: index)
        
        return feedImageCell
    }
    
    func renderedFeedImageData(at index: Int) -> Data? {
        return simulateFeedImageViewVisible(at: index)?.renderedImage
    }
    
    func simulateFeedImageViewNearVisible(at index: Int) {
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: index, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [index])
    }
    
    func simulateFeedImageViewNearNotVisible(at index: Int) {
        simulateFeedImageViewNearVisible(at: index)
        
        let ds = tableView.prefetchDataSource
        let index = IndexPath(row: index, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [index])
    }
    
    func simulateLoadMoreFeedAction() {
        guard let view = loadMoreCell() else { return }
        
        let delegate = tableView.delegate
        let index = IndexPath(row: 0, section: loadMoreSection)
        delegate?.tableView?(tableView, willDisplay: view, forRowAt: index)
    }
    
    var isShowingLoadMoreFeedIndicator: Bool {
        loadMoreCell()?.isLoading == true
    }
    
    var loadMoreFeedErrorMessage: String? {
        loadMoreCell()?.message
    }
    
    private func loadMoreCell() -> LoadMoreCell? {
        cell(row: 0, section: loadMoreSection) as? LoadMoreCell
    }
}

private class UIRefreshControlSpy: UIRefreshControl {
    private var _isRefreshing = false

    override var isRefreshing: Bool { _isRefreshing }

    override func beginRefreshing() {
        _isRefreshing = true
    }

    override func endRefreshing() {
        _isRefreshing = false
    }
}
