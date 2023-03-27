//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 25/03/23.
//

import UIKit
public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let feedImage = UIImageView()
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc
    func retryButtonTapped() {
        onRetry?()
    }
}
