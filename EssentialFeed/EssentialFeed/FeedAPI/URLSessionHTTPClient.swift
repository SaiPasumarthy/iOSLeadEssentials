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
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session.dataTask(with: url) { data, response, error in
            completion(Result {
                if let error = error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValuesRepresentation()
                }
            })
        }.resume()
    }
}
