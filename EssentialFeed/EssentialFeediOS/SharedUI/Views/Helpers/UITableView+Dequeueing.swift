//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 13/04/23.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return self.dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
