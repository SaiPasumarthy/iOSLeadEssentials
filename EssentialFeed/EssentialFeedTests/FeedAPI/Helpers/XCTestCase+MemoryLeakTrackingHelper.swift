//
//  XCTestCase+MemoryLeakTrackingHelper.swift
//  EssentialFeedTests
//
//  Created by Sai Pasumarthy on 12/02/23.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "SUT instance is not deallocated", file: file, line: line)
        }
    }
}
