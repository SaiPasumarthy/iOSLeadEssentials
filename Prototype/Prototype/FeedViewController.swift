//
//  FeedViewController.swift
//  Prototype
//
//  Created by Sai Pasumarthy on 22/03/23.
//

import Foundation
import UIKit

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let imageName: String
}

final class FeedViewController: UITableViewController {
    private var feed = FeedImageViewModel.prototypeFeed
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}

extension FeedImageCell {
    func configure(with model: FeedImageViewModel) {
        self.feedImageView.image = UIImage(named: model.imageName)
        
        self.descriptionLabel.text = model.description
        self.descriptionLabel.isHidden = model.description == nil
        
        self.locationLabel.text = model.location
        self.locationLabel.isHidden = model.location == nil
    }
}
