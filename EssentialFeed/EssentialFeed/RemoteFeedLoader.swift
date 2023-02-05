//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 05/02/23.
//

import Foundation

#warning("How client of RemoteFeedLoader doesn't knows about HTTPClient when it dependancy injects through init")
#warning("Who is the client of RemoteFeedLoader? Is it whoever instantiate the RemoteFeedLoader class?")
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    #warning("URL is detail implementation and shouldn't be in public interface. But the doubt is how does every client of RemoteFeedLoader know of url to request data from")
    public func load() {
        client.get(from: url)
    }
}
#warning("Benifit of being protocol is, don't need to create new type to confirm to it. We can create easily extension on URLSession conform to protocol")
public protocol HTTPClient {
    func get(from url: URL)
}
