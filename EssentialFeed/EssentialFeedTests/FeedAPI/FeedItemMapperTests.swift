//
//  FeedItemMapperTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 04/02/23.
//

import XCTest
import EssentialFeed

// Test name is like test_<methodName>_<behaviourToTest>
class FeedItemMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPResponse() throws {
        let json = makeItemsJSON([])
        let samples = [199, 201, 300, 400, 501]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOnNon200HTTPResponseWithInvalidJSON() {
        let invalidJSON = Data.init("invalidJSON".utf8)

        XCTAssertThrowsError(
            try FeedItemMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyJSON = makeItemsJSON([])
        
        let result = try FeedItemMapper.map(emptyJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_deliversItemsOn200HTTPResponseWithValidJsonList() throws {
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url-given.com")!)
        let item2 = makeItem(id: UUID(), description: "aDesc", location: "aLoc", imageURL: URL(string: "https://a-url-given-2.com")!)
        let json = makeItemsJSON([item1.json, item2.json])
        
        let result = try FeedItemMapper.map(json, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [item1.model, item2.model])
    }
    
    // MARK: - Helpers
        
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeItem(id: UUID, description: String? = nil, location: String? = nil, imageURL: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let json = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        return (item, json)
    }
    private func makeItemsJSON(_ items: [[String: Any]]) -> Data {
        let itemsJson = ["items" : items]
        return try! JSONSerialization.data(withJSONObject: itemsJson)
    }
}

private extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
