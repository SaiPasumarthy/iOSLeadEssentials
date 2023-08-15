//
//  ImageCommentsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 15/08/23.
//

import XCTest
import EssentialFeed

// Test name is like test_<methodName>_<behaviourToTest>
class ImageCommentsMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon2xxHTTPResponse() throws {
        let samples = [199, 150, 300, 400, 501]
        let json = makeItemsJSON([])
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn2xxHTTPResponseWithInvalidJSON() throws {
        let samples = [200, 201, 250, 280, 299]
        let invalidJSON = Data.init("invalidJSON".utf8)
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try ImageCommentsMapper.map(invalidJSON, response: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() throws {
        let samples = [200, 201, 250, 280, 299]
        let emptyJSON = makeItemsJSON([])
        
        try samples.forEach { code in
            let result = try ImageCommentsMapper.map(emptyJSON, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [])
        }
    }
    
    func test_map_deliversItemsOn2xxHTTPResponseWithJsonItems() throws {
        let item1 = makeItem(
            id: UUID(),
            message: "a message",
            createdAt: (Date(timeIntervalSince1970: 1598627222), "2020-08-28T15:07:02+00:00"),
            username: "a username")
        let item2 = makeItem(
            id: UUID(),
            message: "another message",
            createdAt: (Date(timeIntervalSince1970: 1577881882), "2020-01-01T12:31:22+00:00"),
            username: "another username"
        )
        
        let samples = [200, 201, 250, 280, 299]
        let json = makeItemsJSON([item1.json, item2.json])
        
        try samples.enumerated().forEach { index, code in
            let result = try ImageCommentsMapper.map(json, response: HTTPURLResponse(statusCode: code))
            XCTAssertEqual(result, [item1.model, item2.model])
        }
    }
  
    // MARK: - Helpers
    
    private func makeItem(id: UUID, message: String, createdAt: (date: Date, iso8610String: String), username: String) -> (model: ImageComment, json: [String: Any]) {
        let item = ImageComment(id: id, message: message, createdAt: createdAt.date, username: username)
        let json: [String: Any] = [
            "id": id.uuidString,
            "message": message,
            "created_at": createdAt.iso8610String,
            "author": [
                "username": username
            ]
        ]
        return (item, json)
    }
}
