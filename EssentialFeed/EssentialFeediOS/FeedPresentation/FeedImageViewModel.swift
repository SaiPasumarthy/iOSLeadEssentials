//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 02/04/23.
//

import Foundation
import EssentialFeed

final class FeedImageViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
    
    init(description: String? = nil, location: String?, image: Image?, isLoading: Bool, shouldRetry: Bool) {
        self.description = description
        self.location = location
        self.image = image
        self.isLoading = isLoading
        self.shouldRetry = shouldRetry
    }
}
