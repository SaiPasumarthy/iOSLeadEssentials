//
//  LoadImageCommentsFromRemoteUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 15/08/23.
//

import XCTest
import EssentialFeed

// Test name is like test_<methodName>_<behaviourToTest>
class LoadImageCommentsFromRemoteUseCaseTests: XCTestCase {
    
    func test_init_doesnotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestDataFromURL() {
        let url = URL(string: "https://a-url-given.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url-given.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        expect(sut, toCompleteWithResult: failure(.connectivity)) {
            
            let error = NSError(domain: "Test", code: 0)
            client.complete(with: error)
        }
    }
    
    func test_load_deliversErrorOnNon2xxHTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 150, 300, 400, 501]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let json = makeItemsJSON([])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_deliversErrorOn2xxHTTPResponseWithInvalidJSON() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: failure(.invalidData)) {
                let invalidJSON = Data.init("invalidJSON".utf8)
                client.complete(withStatusCode: code, data: invalidJSON, at: index)
            }
        }
    }
    
    func test_load_deliversNoItemsOn2xxHTTPResponseWithEmptyJSONList() {
        let (sut, client) = makeSUT()
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .success([])) {
                let emptyJSON = makeItemsJSON([])
                client.complete(withStatusCode: code, data: emptyJSON, at: index)
            }
        }
    }
    
    func test_load_deliversItemsOn2xxHTTPResponseWithJsonItems() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), description: nil, location: nil, imageURL: URL(string: "https://a-url-given.com")!)
        let item2 = makeItem(id: UUID(), description: "aDesc", location: "aLoc", imageURL: URL(string: "https://a-url-given-2.com")!)
        
        let samples = [200, 201, 250, 280, 299]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWithResult: .success([item1.model, item2.model])) {
                let json = makeItemsJSON([item1.json, item2.json])
                client.complete(withStatusCode: code, data: json, at: index)
            }
        }
    }
    
    func test_load_doesnotDeliverResultOnceSUTHasBeenDeallocated() {
        let url = URL(string: "https://a-url.com")!
        let client = HTTPClientSpy()
        var sut: RemoteImageCommentsLoader? = RemoteImageCommentsLoader(url: url, client: client)
       
        var capturedResult = [RemoteImageCommentsLoader.Result]()
        sut?.load(completion: { capturedResult.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemsJSON([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteImageCommentsLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteImageCommentsLoader(url: url, client: client)
        trackForMemoryLeaks(sut)
        trackForMemoryLeaks(client)
        return (sut, client)
    }
        
    private func expect(_ sut: RemoteImageCommentsLoader, toCompleteWithResult expectedResult: RemoteImageCommentsLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let expectation = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteImageCommentsLoader.Error), .failure(expectedError as RemoteImageCommentsLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)

            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead.", file: file, line: line)
            }
            expectation.fulfill()
        }
        
        action()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteImageCommentsLoader.Error) -> RemoteImageCommentsLoader.Result {
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
