//
//  FeedImagePresenter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 06/04/23.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location
        )
    }
}
