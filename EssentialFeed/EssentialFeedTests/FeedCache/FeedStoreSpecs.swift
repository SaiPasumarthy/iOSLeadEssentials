//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 12/03/23.
//

import Foundation

typealias FailableFeedStoreSpecs = FailableRetrieveFeedStoreSpecs & FailableInsertFeedStoreSpecs & FailableDeleteFeedStoreSpecs

protocol FeedStoreSpecs {
    func test_retrieval_deliversEmptyOnEmptyCache()
    func test_retrieval_hasNoSideEffectsOnEmptyCache()
    func test_retrieval_deliversFoundValuesOnNonEmptyCache()
    func test_retrieval_hasNoSideEffectsOnNonEmptyCache()
    
    func test_insert_overridesPreviousInsertedCacheValues()

    func test_delete_hasNoSideEffectsOnEmptyCache()
    func test_delete_emptiesPreviouslyInsertedCache()

    func test_storeSideEffects_runSerially()
}

protocol FailableRetrieveFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieval_deliversFailureOnRetrievalError()
    func test_retrieval_hasNoSideEffectsOnFailure()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversErrorOnInsertionError()
    func test_insert_hasNoSideEffectsOnFailure()
}

// This has problem since cachedirectory has permission to delete could not able simulate the delete failure
protocol FailableDeleteFeedStoreSpecs: FeedStoreSpecs {
}
