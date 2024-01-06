//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 14/05/23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?

    @available(*, deprecated)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
    @available(*, deprecated)
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
}

public extension FeedImageDataStore {
    func insert(data: Data, for url: URL) throws {
        let group = DispatchGroup()
        group.enter()
        var result: InsertionResult!
        
        insert(data: data, for: url) {
            result = $0
            group.leave()
        }
        group.wait()
        
        return try result.get()
    }
    
    func retrieve(dataForURL url: URL) throws -> Data? {
        let group = DispatchGroup()
        group.enter()
        var result: RetrievalResult!
        
        retrieve(dataForURL: url) {
            result = $0
            group.leave()
        }
        group.wait()
        
        return try result.get()
    }
    
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void) {}
    func insert(data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {}
}
