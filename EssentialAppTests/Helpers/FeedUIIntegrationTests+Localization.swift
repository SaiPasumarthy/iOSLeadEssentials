//
//  FeedUIIntegrationTests+Localization.swift
//  EssentialAppTests
//
//  Created by Sai Pasumarthy on 17/06/23.
//

import EssentialFeed
import XCTest

extension FeedUIIntegrationTests {
    private class DummyView: ResourceView {
        func display(viewModel: Any) {
        }
    }
    var loadError: String {
        LoadResourcePresenter<Any, DummyView>.loadError
    }
    
    var feedTitle: String {
        FeedPresenter.feedTitle
    }
}
