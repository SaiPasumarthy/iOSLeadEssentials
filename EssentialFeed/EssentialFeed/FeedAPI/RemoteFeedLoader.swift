//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 05/02/23.
//

import Foundation

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemMapper.map)
    }
}

#warning("How client of RemoteFeedLoader doesn't knows about HTTPClient when it dependancy injects through init")
#warning("Who is the client of RemoteFeedLoader? Is it whoever instantiate the RemoteFeedLoader class?")
#warning("URL is detail implementation and shouldn't be in public interface. But the doubt is how does every client of RemoteFeedLoader know of url to request data from")
