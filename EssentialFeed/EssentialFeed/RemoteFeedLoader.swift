//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 05/02/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

#warning("Benifit of being protocol is, don't need to create new type to confirm to it. We can create easily extension on URLSession conform to protocol")
public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

#warning("How client of RemoteFeedLoader doesn't knows about HTTPClient when it dependancy injects through init")
#warning("Who is the client of RemoteFeedLoader? Is it whoever instantiate the RemoteFeedLoader class?")
public final class RemoteFeedLoader {
    private let url: URL
    private let client: HTTPClient
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
#warning("URL is detail implementation and shouldn't be in public interface. But the doubt is how does every client of RemoteFeedLoader know of url to request data from")
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .success(let data, let response):
                if let items = try? FeedItemMapper.map(data, response) {
                    completion(.success(items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private class FeedItemMapper {
        private struct Root: Decodable {
            let items: [Item]
        }
        
        private struct Item: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
            
            var item: FeedItem {
                FeedItem(id: id, description: description, location: location, imageURL: image)
            }
        }
        
        static var OK_200: Int { return 200 }
        
        static func map(_ data: Data, _ response: HTTPURLResponse) throws -> [FeedItem] {
            guard response.statusCode == OK_200 else {
                throw RemoteFeedLoader.Error.invalidData
            }
            let root = try JSONDecoder().decode(Root.self, from: data)
            return root.items.map { $0.item }
        }
    }
}
