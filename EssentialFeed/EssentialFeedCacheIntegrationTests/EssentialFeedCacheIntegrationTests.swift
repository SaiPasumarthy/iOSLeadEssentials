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
        let sut = makeFeedLoader()
        
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeperateInstance() {
        let sutToPerformSave = makeFeedLoader()
        let sutToPerformLoad = makeFeedLoader()
        let feed = uniqueImageFeed().models

        save(feed, with: sutToPerformSave)
        
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overridesItemsSavedOnASeperateInstance() {
        let sutToPerformFirstSave = makeFeedLoader()
        let sutToPerformLastSave = makeFeedLoader()
        let sutToPerformLoad = makeFeedLoader()
        let latestFeed = uniqueImageFeed().models

        save(uniqueImageFeed().models, with: sutToPerformFirstSave)
        save(latestFeed, with: sutToPerformLastSave)
        
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    // MARK: - Helpers
    
    private func makeImageLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return sut
    }
    
    private func makeFeedLoader(file: StaticString = #filePath, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = try! CoreDataFeedStore(storeURL: storeURL)
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
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #filePath, line: UInt = #line) {
        let expectationForSave = expectation(description: "Waiting for save on disk")
        loader.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
            }
            expectationForSave.fulfill()
        }
        wait(for: [expectationForSave], timeout: 1.0)
    }
    
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #filePath, line: UInt = #line) {
        let saveExp = expectation(description: "Waiting for save on disk")
        loader.save(data: data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Waiting for load result")
        
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case let .success(receivedData):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case .failure:
                XCTFail("Expected success but got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
