//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Sai Pasumarthy on 22/03/23.
//

import Foundation
import UIKit

final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        feedImageView.alpha = 0
    }
    
    func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        UIView.animate(withDuration: 0.3, delay: 0.3, options: []) { [weak self] in
            self?.feedImageView.alpha = 1
        }
    }
}
