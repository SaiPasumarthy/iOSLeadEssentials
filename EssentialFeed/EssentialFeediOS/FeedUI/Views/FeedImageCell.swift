//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 25/03/23.
//

import UIKit
public final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) public var locationContainer: UIView!
    @IBOutlet private(set) public var locationLabel: UILabel!
    @IBOutlet private(set) public var descriptionLabel: UILabel!
    @IBOutlet private(set) public var imageContainer: UIView!
    @IBOutlet private(set) public var feedImage: UIImageView!
    @IBOutlet private(set) public var feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func retryButtonTapped() {
        onRetry?()
    }
}
