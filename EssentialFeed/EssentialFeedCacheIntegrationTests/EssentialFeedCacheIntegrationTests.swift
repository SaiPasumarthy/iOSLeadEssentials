//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Sai Pasumarthy on 17/03/23.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {

    override func setUp() {
        cleanUpDisk()
    }
    
    override func tearDown() {
        undoDiskArtifacts()
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeperateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().models

        save(feed, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeperateInstance() {
        let sutToPerformFirstSave = makeSUT()
        let sutToPerformLastSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let latestFeed = uniqueImageFeed().models

        save(uniqueImageFeed().models, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: bundle)
        let sut = LocalFeedLoader(store: store, timestamp: Date.init)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load result")
        
        sut.load { result in
            switch result {
            case let .success(images):
                XCTAssertEqual(images, expectedFeed, file: file, line: line)
            case .failure:
                XCTFail("Expected success but got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
    
        wait(for: [exp], timeout: 1.0)
    }
    
    private func save(_ feed: [FeedImage], with sut: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let expectationForSave = expectation(description: "Waiting for save on disk")
        sut.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTAssertNil(error, file: file, line: line)
            }
            expectationForSave.fulfill()
        }
        wait(for: [expectationForSave], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return  cacheDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cacheDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func cleanUpDisk() {
        deleteDataOnDisk()
    }
    
    private func undoDiskArtifacts() {
        deleteDataOnDisk()
    }
    
    private func deleteDataOnDisk() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
