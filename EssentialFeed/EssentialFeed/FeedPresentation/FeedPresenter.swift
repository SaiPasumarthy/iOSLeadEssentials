//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 04/05/23.
//

import Foundation

public final class FeedPresenter {
    public static var feedTitle: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Title for the feed view")
    }
    
    public static func map(_ feed: [FeedImage]) -> FeedViewModel {
        FeedViewModel(feed: feed)
    }
}
