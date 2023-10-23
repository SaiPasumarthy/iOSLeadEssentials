//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Sai Pasumarthy on 14/04/23.
//

import XCTest
import EssentialFeed

class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValuesExist(in: bundle, table)
    }
}
