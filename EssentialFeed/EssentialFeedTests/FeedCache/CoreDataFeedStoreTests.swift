//
//  CoreDataFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 16/03/23.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
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

    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
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
    
    //MARK: - Helpers
        
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> FeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
}

