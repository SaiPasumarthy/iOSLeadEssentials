//
//  FeedEndPoint.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 05/12/23.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
