//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 02/04/23.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    private var feedLoader: FeedLoader?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onChange: ((FeedViewModel) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    private(set) var isLoading: Bool = false { didSet { onChange?(self) } }
    
    func loadFeed() {
        isLoading = true
        self.feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.isLoading = false
        }
    }
}
