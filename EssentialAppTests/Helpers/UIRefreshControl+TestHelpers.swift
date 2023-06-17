//
//  UIRefreshControl+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import UIKit

extension UIRefreshControl {
    func simulatePullRefresh() {
        self.allTargets.forEach { target in
            self.actions(forTarget: target,
                                        forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
