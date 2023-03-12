//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 09/02/23.
//

import Foundation

public enum HTTPClientResult {
    case success(Data, HTTPURLResponse)
    case failure(Error)
}

#warning("Benifit of being protocol is, don't need to create new type to confirm to it. We can create easily extension on URLSession conform to protocol")
public protocol HTTPClient {
    /// The Completion handler can be invoke in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
