//
//  FeedErrorViewModel.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 04/05/23.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel {
        return FeedErrorViewModel(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewModel {
        return FeedErrorViewModel(message: message)
    }
}
