//
//  HTTPClient.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 09/02/23.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    /// The Completion handler can be invoke in any thread
    /// Clients are responsible to dispatch to appropriate thread, if needed
    @discardableResult
    func get(from url: URL, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
