//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 11/03/23.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
    }
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        var localFeed: [LocalFeedImage] {
            feed.map { $0.local }
        }
    }
    
    
    func retrieval(with completion: @escaping FeedStore.RetrievalCompletion) {
        let decoder = JSONDecoder()
        guard let data = try? Data(contentsOf: storeURL) else { return completion(.empty) }
        
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(images: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date,
                completion: @escaping FeedStore.InsertionCompletion) {
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let data = try! encoder.encode(cache)
        try! data.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {

    override func setUp() {
        super.setUp()
        
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    func test_retrieval_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for expectation")
        sut.retrieval { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty but got \(result)")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieval_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "Wait for expectation")
        sut.retrieval { firstResult in
            sut.retrieval { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    break
                default:
                    XCTFail("Expected empty but got \(firstResult) and \(secondResult)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for expectation")

        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected insertion error is nil")
            sut.retrieval { result in
                switch result {
                case let .found(receivedImages, receivedTimestamp):
                    XCTAssertEqual(feed, receivedImages)
                    XCTAssertEqual(timestamp, receivedTimestamp)
                    break
                default:
                    XCTFail("Expected images and timestamp but got \(result)")
                }
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "Wait for expectation")

        sut.insert(feed, timestamp: timestamp) { insertionError in
            XCTAssertNil(insertionError, "Expected insertion error is nil")
            
            sut.retrieval { firstResult in
                sut.retrieval { secondResult in
                    switch (firstResult, secondResult) {
                    case let (.found(firstImages, firstTimestamp), .found(secondImages, secondTimestamp)):
                        XCTAssertEqual(feed, firstImages)
                        XCTAssertEqual(timestamp, firstTimestamp)
                        XCTAssertEqual(feed, secondImages)
                        XCTAssertEqual(timestamp, secondTimestamp)
                        break
                    default:
                        XCTFail("Expected images and timestamp but got \(firstResult) and second \(secondResult)")
                    }
                }
            }

            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    //MARK: Helpers
    
    private func testSpecificStoreURL() -> URL {
      return  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
