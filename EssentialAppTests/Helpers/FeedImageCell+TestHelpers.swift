//
//  FeedImageCell+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import EssentialFeediOS
import UIKit

extension FeedImageCell {
    var isShowingLocation: Bool {
        return !locationContainer.isHidden
    }
    var locationText: String? {
        return locationLabel.text
    }
    var descriptionText: String? {
        return descriptionLabel.text
    }
    var isShowingImageLoadingIndicator: Bool {
        return self.imageContainer.isShimmering
    }
    var renderImage: Data? {
        return self.feedImage.image?.pngData()!
    }
    var isShowRetryAction: Bool {
        return !self.feedImageRetryButton.isHidden
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}
