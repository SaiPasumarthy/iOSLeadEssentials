//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 09/02/23.
//

import Foundation

final class FeedItemMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
        
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
