//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 28/04/23.
//

import UIKit

public final class ErrorView: UIView {
    @IBOutlet private(set) public var button: UIButton!
    
    public var errorMessage: String? {
        get { return isVisible ? button.title(for: .normal) : nil }
    }
    
    private var isVisible: Bool {
        return self.alpha > 0
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        button.setTitle(nil, for: .normal)
        self.alpha = 0
    }
    
    func show(message: String?) {
        if let message = message {
            button.setTitle(message, for: .normal)
            
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
            }
        } else {
            hideMessage()
        }
    }
    
    @IBAction func hideMessage() {
        UIView.animate(withDuration: 0.25, animations: { self.alpha = 0 }) { completed in
            if completed {
                self.button.setTitle(nil, for: .normal)
            }
        }
    }
}
