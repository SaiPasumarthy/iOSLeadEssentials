//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 28/04/23.
//

import Foundation

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
