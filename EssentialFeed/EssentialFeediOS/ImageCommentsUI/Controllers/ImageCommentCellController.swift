//
//  ImageCommentCellController.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 29/10/23.
//

import UIKit
import EssentialFeed

public final class ImageCommentCellController: CellControler {
    private let model: ImageCommentViewModel
    
    public init(model: ImageCommentViewModel) {
        self.model = model
    }
    
    public func view(in tableView: UITableView) -> UITableViewCell {
        let cell: ImageCommentCell = tableView.dequeueReusableCell()
        cell.messageLabel.text = model.message
        cell.usernameLabel.text = model.username
        cell.dateLabel.text = model.date
        return cell
    }
}
