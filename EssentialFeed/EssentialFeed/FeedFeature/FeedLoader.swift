//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 03/02/23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
