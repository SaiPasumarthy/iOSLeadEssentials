//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 01/07/23.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
