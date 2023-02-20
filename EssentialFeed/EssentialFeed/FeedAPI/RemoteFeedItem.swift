//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 20/02/23.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
