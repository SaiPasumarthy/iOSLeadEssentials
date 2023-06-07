//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 07/06/23.
//

import Foundation
import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private struct Task: FeedImageDataLoaderTask {
        func cancel() { }
    }
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return Task()
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {
    
    func test_init_doesNotLoadImageData() {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    
    private func anyURL() -> URL {
        return URL(string: "https://a-url.com")!
    }
    
    // MARK: - Helpers
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() { }
        }
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url: url, completion: completion))
            
            return Task()
        }
    }
}


//func test_load_deliversPrimaryImageOnPrimaryImageDataLoaderSuccess() {
//    let primaryData = Data("primary data".utf8)
//    let fallbackData = Data("fallback data".utf8)
//
//    let primaryImageLoader = ImageLoaderStub(result: .success(primaryData))
//    let fallbackImageLoader = ImageLoaderStub(result: .success(fallbackData))
//
//    let sut = FeedImageDataLoaderWithFallbackComposite(primaryLoader: primaryImageLoader, fallbackLoader: fallbackImageLoader)
//    let exp = expectation(description: "Waiting for image data load completion")
//
//    _ = sut.loadImageData(from: anyURL()) { result in
//        switch result {
//        case let .success(receivedData):
//            XCTAssertEqual(receivedData, primaryData)
//
//        case .failure:
//            XCTFail("Expected Successfull response, got \(result) instead")
//        }
//
//        exp.fulfill()
//    }
//
//    wait(for: [exp], timeout: 1.0)
//}
//
//
//private func anyURL() -> URL {
//    return URL(string: "https://a-url.com")!
//}
//
//class ImageLoaderStub: FeedImageDataLoader {
//    private let result: FeedImageDataLoader.Result
//    init(result: FeedImageDataLoader.Result) {
//        self.result = result
//    }
//    struct Task: FeedImageDataLoaderTask {
//
//        func cancel() {
//
//        }
//    }
//
//    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
//        completion(result)
//
//        return Task()
//    }
//}
