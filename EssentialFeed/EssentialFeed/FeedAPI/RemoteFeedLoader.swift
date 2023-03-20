//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 05/02/23.
//

import Foundation

#warning("How client of RemoteFeedLoader doesn't knows about HTTPClient when it dependancy injects through init")
#warning("Who is the client of RemoteFeedLoader? Is it whoever instantiate the RemoteFeedLoader class?")
public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = FeedLoader.Result

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
#warning("URL is detail implementation and shouldn't be in public interface. But the doubt is how does every client of RemoteFeedLoader know of url to request data from")
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let data, let response):
                completion(RemoteFeedLoader.map(data, with: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private static func map(_ data: Data, with response: HTTPURLResponse) -> Result {
        do {
            let items = try FeedItemMapper.map(data, from: response)
            return .success(items.toModels())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        return map {
            FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image)
        }
    }
}
