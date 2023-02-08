//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 03/02/23.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
