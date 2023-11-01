//
//  FeedViewController+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import EssentialFeediOS
import UIKit

extension ListViewController {
    public override func loadViewIfNeeded() {
        super.loadViewIfNeeded()
        
        tableView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    }
    func simulateUserInitiatedReload() {
        refreshControl?.simulatePullRefresh()
    }
    var isShowingLoadingIndicator: Bool? {
        return refreshControl?.isRefreshing
    }
    
    func numberOfRenderedFeedImageViews() -> Int {
        tableView.numberOfSections == 0 ? 0 :  tableView.numberOfRows(inSection: feedImageSection)
    }
    
    private var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at index: Int) -> UITableViewCell? {
        guard numberOfRenderedFeedImageViews() > index else {
            return nil
        }
        let ds = tableView.dataSource
        let index = IndexPath(row: index, section: feedImageSection)
        return ds?.tableView(tableView, cellForRowAt: index)
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
    
    func simulateErrorViewTap() {
        errorView.simulateTap()
    }
    
    var errorMessage: String? {
        return errorView.errorMessage
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
}
