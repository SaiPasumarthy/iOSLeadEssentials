//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 11/03/23.
//

import XCTest
import EssentialFeed

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
        
        expect(sut, toRetrive: .empty)
    }
    
    func test_retrieval_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetriveTwice: .empty)
    }
    
    func test_retrieval_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), sut: sut)
        
        expect(sut, toRetrive: .found(images: feed, timestamp: timestamp))
    }
    
    func test_retrieval_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), sut: sut)
        
        expect(sut, toRetriveTwice: .found(images: feed, timestamp: timestamp))
    }
    
    func test_retrieval_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrive: .failure(anyNSError()))
    }
    
    func test_retrieval_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: testSpecificStoreURL(), atomically: false, encoding: .utf8)
        
        expect(sut, toRetriveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviousInsertedCacheValues() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), sut: sut)
        XCTAssertNil(insertionError, "Expect insertion error to be nil")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let latestInsertionError = insert((latestFeed, latestTimestamp), sut: sut)
     
        XCTAssertNil(latestInsertionError, "Expect latest insertion error to be nil")
        expect(sut, toRetrive: .found(images: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let storeURL = URL(string: "https://any-url.com")!
        let sut = makeSUT(storeURL: storeURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), sut: sut)
        XCTAssertNotNil(insertionError, "Expect insertion error not to be nil")
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect deletion error to be nil")
        expect(sut, toRetrive: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), sut: sut)
        XCTAssertNil(insertionError, "Expect insertion error to be nil")
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect deletion error to be nil")
        expect(sut, toRetrive: .empty)
    }
    
//    func test_delete_deliversErrorOnDeletionError() {
//        let noPermissionErrorURL = cacheDirectoryURL()
//        let sut = makeSUT(storeURL: noPermissionErrorURL)
//
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNotNil(deletionError, "Expect deletion error not to be nil")
//    }
    
    //MARK: Helpers
    
    private func testSpecificStoreURL() -> URL {
      return  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

//    private func cacheDirectoryURL() -> URL {
//        return  FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
//    }
    
    private func expect(_ sut: FeedStore, toRetriveTwice expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        expect(sut, toRetrive: expectedResult, file: file, line: line)
        expect(sut, toRetrive: expectedResult, file: file, line: line)
    }
    
    private func expect(_ sut: FeedStore, toRetrive expectedResult: RetrievalCachedFeedResult, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for expectation")
        sut.retrieval { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(receivedImages, receivedTimestamp), .found(expectedImages, expectedTimestamp)):
                XCTAssertEqual(receivedImages, expectedImages, file: file, line: line)
                XCTAssertEqual(receivedTimestamp, expectedTimestamp, file: file, line: line)
            default:
                XCTFail("Expected empty but got \(receivedResult)", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for expectation")
        var insertionError: Error? = nil
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedError in
            insertionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    private func deleteCache(from sut: FeedStore, file: StaticString = #filePath, line: UInt = #line) -> Error? {
        let exp = expectation(description: "Wait for expectation")
        var deleteError: Error? = nil
        sut.deleteCachedFeed { receivedError in
            deleteError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        
        return deleteError
    }
    
    private func makeSUT(storeURL url: URL? = nil, file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: url ?? testSpecificStoreURL())
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
