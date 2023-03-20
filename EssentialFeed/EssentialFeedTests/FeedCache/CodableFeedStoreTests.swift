//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 11/03/23.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {

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
        
        expect(sut, toRetrive: .success(.none))
    }
    
    func test_retrieval_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetriveTwice: .success(.none))
    }
    
    func test_retrieval_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), sut: sut)
        
        expect(sut, toRetrive: .success(.some(CacheFeed(images: feed, timestamp: timestamp))))
    }
    
    func test_retrieval_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), sut: sut)
        
        expect(sut, toRetriveTwice: .success(.some(CacheFeed(images: feed, timestamp: timestamp))))
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
        expect(sut, toRetrive: .success(.some(CacheFeed(images: latestFeed, timestamp: latestTimestamp))))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidURL = URL(string: "invalid://any-url.com")!
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), sut: sut)
        XCTAssertNotNil(insertionError, "Expect insertion error not to be nil")
    }
    
    func test_insert_hasNoSideEffectsOnFailure() {
        let invalidURL = URL(string: "invalid://any-url.com")!
        let sut = makeSUT(storeURL: invalidURL)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert((feed, timestamp), sut: sut)
        
        expect(sut, toRetrive: .success(.none))
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect deletion error to be nil")
        expect(sut, toRetrive: .success(.none))
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        let insertionError = insert((uniqueImageFeed().local, Date()), sut: sut)
        XCTAssertNil(insertionError, "Expect insertion error to be nil")
        
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "Expect deletion error to be nil")
        expect(sut, toRetrive: .success(.none))
    }
    
//    func test_delete_deliversErrorOnDeletionError() {
//        let noPermissionErrorURL = cacheDirectoryURL()
//        let sut = makeSUT(storeURL: noPermissionErrorURL)
//
//        let deletionError = deleteCache(from: sut)
//
//        XCTAssertNotNil(deletionError, "Expect deletion error not to be nil")
//    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT(storeURL: testSpecificStoreURL())
        var completedOperationInOrder = [XCTestExpectation]()
        
        let op1 = expectation(description: "Wait for operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationInOrder.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Wait for operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationInOrder.append(op2)
            op2.fulfill()
        }

        let op3 = expectation(description: "Wait for operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            completedOperationInOrder.append(op3)
            op3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationInOrder, [op1, op2, op3])
    }
    
    //MARK: Helpers
    
    private func testSpecificStoreURL() -> URL {
        return  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }

//    private func cacheDirectoryURL() -> URL {
//        return  FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
//    }
    
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
