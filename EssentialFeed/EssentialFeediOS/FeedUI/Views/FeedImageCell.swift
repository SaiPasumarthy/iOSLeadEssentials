//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 25/03/23.
//

import UIKit
import SwiftUI

struct FeedImageCellView: View {
    private var viewModel: FeedImageViewModel<UIImage>
    @State var myImage: UIImage?
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
        viewModel.onImageLoad = { image in
            myImage = image
        }
    }
    func loadImage(data: Data) -> UIImage {
        
    }
    var body: some View {
        HStack {
            if let myImage = myImage {
                Image(uiImage: myImage)
            }
        }
    }
}

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let imageContainer = UIView()
    public let feedImage = UIImageView()
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc
    func retryButtonTapped() {
        onRetry?()
    }
}
