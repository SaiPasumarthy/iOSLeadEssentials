//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 28/04/23.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
