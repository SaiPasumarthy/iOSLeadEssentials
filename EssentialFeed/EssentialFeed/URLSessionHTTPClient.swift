//
//  URLSessionHTTPClient.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 12/02/23.
//

import Foundation

#warning("How this production code is free to refactor in the future to use AFNetowrking or to keep using new APIs from URLSession")
public class URLSessionHTTPClient: HTTPClient {
    private var session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success(data, response))
            } else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
        }.resume()
    }
}
