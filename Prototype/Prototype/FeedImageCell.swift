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
}
