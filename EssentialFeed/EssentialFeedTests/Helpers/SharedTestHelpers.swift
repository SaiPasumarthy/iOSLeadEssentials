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

func makeItemsJSON(_ items: [[String: Any]]) -> Data {
    let itemsJson = ["items" : items]
    return try! JSONSerialization.data(withJSONObject: itemsJson)
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
    
    func adding(minutes: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .minute, value: minutes, to: self)!
    }
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}
