//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 02/04/23.
//

import Foundation
import EssentialFeed

final class FeedViewModel {
    typealias Observer<T> = (T) -> Void
    private var feedLoader: FeedLoader?

    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLodingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
        
    func loadFeed() {
        onLodingStateChange?(true)
        self.feedLoader?.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onLodingStateChange?(false)
        }
    }
}
