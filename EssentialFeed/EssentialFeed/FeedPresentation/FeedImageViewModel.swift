//
//  FeedImageViewModel.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 02/04/23.
//

import Foundation

public final class FeedImageViewModel {
    public let description: String?
    public let location: String?
    
    public var hasLocation: Bool {
        return location != nil
    }
    
    public init(description: String? = nil, location: String?) {
        self.description = description
        self.location = location
    }
}
