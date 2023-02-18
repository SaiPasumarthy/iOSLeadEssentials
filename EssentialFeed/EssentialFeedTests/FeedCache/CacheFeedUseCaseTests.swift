//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 18/02/23.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed { [unowned self] error in
            if error == nil {
                self.store.insert(items)
            }
        }
    }
}

class FeedStore {
    typealias DeletionCompletion = ((Error?) -> Void)
    
    var deleteCacheFeedCallCount: Int = 0
    var insertCallCount: Int = 0
    private var deletionCompletions: [DeletionCompletion] = []
    
    func deleteCachedFeed(with completion: @escaping DeletionCompletion) {
        deleteCacheFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0) {
        deletionCompletions[0](error)
    }
    
    func completeDeletionSuccessFully(at index: Int = 0) {
        deletionCompletions[0](nil)
    }
    
    func insert(_ items: [FeedItem]) {
        insertCallCount += 1
    }
}
class CacheFeedUseCaseTests: XCTestCase {

    func test_init_doesnotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(), uniqueItem()])
        
        XCTAssertEqual(store.deleteCacheFeedCallCount, 1)
    }
    
    func test_save_doesnotRequestCacheInsertionUponDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save([uniqueItem(), uniqueItem()])
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.insertCallCount, 0)
    }
    
    func test_save_requestsNewCacheInsertionOnSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save([uniqueItem(), uniqueItem()])
        store.completeDeletionSuccessFully()
        
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    //MARK: - Helpers
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "https://a-url.com")!
    }

    private func anyNSError() -> NSError {
        return NSError(domain: "a error", code: 1)
    }
}
