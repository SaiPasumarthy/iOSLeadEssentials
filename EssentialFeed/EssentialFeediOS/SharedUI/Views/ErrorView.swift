//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 28/04/23.
//

import UIKit

public final class ErrorView: UIButton {
    public var errorMessage: String? {
        get { return isVisible ? configuration?.title : nil }
        set { setMessageAnimated(newValue) }
    }
    
    public var onHide: (() -> Void)?
    
    private var isVisible: Bool {
        return self.alpha > 0
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private var titleAttributes: AttributeContainer {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.center
        
        var attributes = AttributeContainer()
        attributes.paragraphStyle = paragraphStyle
        attributes.font = UIFont.preferredFont(forTextStyle: .body)
        return attributes
    }
    
    private func configure() {
        var configuration = Configuration.plain()
        configuration.titlePadding = 0
        configuration.baseForegroundColor = .white
        configuration.background.backgroundColor = .errorBackgroundColor
        configuration.background.cornerRadius = 0
        self.configuration = configuration
        
        addTarget(self, action: #selector(hideMessageAnimated), for: .touchUpInside)
        hideMessage()
    }
    
    private func setMessageAnimated(_ message: String?) {
        if message != nil {
            show(message: message)
        } else {
            hideMessageAnimated()
        }
    }
    func show(message: String?) {
        if let message = message {
            configuration?.attributedTitle = AttributedString(message, attributes: titleAttributes)
            configuration?.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
            
            UIView.animate(withDuration: 0.25) {
                self.alpha = 1
            }
        } else {
            hideMessageAnimated()
        }
    }
    
    @objc private func hideMessageAnimated() {
        UIView.animate(withDuration: 0.25, animations: { self.alpha = 0 }) { completed in
            if completed {
                self.hideMessage()
            }
        }
    }
    
    private func hideMessage() {
        self.alpha = 0
        configuration?.attributedTitle = nil
        configuration?.contentInsets = .zero
        onHide?()
    }
}

extension UIColor {
    static var errorBackgroundColor: UIColor {
        UIColor(red: 0.99951404330000004, green: 0.41759261489999999, blue: 0.4154433012, alpha: 1)
    }
}
