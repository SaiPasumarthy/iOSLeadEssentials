//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 07/06/23.
//

import Foundation
import EssentialFeed

func anyNSError() -> NSError {
    return NSError(domain: "a error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://a-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}

func uniqueFeed() -> [FeedImage] {
    return [FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())]
}
