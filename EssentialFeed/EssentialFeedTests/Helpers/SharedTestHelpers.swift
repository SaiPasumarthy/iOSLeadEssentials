//
//  SharedTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 06/03/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "a error", code: 1)
}

func anyURL() -> URL {
    return URL(string: "https://a-url.com")!
}

func anyData() -> Data {
    return Data("any data".utf8)
}
