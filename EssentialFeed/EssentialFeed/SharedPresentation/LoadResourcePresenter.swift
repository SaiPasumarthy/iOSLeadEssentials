//
//  LoadResourcePresenter.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 23/10/23.
//

import Foundation

public protocol ResourceView {
    associatedtype ResourceViewModel
    func display(viewModel: ResourceViewModel)
}

public final class LoadResourcePresenter<Resource, View: ResourceView> {
    public typealias Mapper = (Resource) throws -> View.ResourceViewModel
    private let resourceView: View
    private let errorView: ResourceErrorView
    private let loadingView: ResourceLoadingView
    private let mapper: Mapper
    
    public init(resourceView: View, loadingView: ResourceLoadingView, errorView: ResourceErrorView, mapper: @escaping Mapper) {
        self.resourceView = resourceView
        self.loadingView = loadingView
        self.errorView = errorView
        self.mapper = mapper
    }

    public static var loadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: Self.self),
                                 comment: "Error message displayed when we can't load the resource from the server")
    }
    
    public func didStartLoading() {
        errorView.display(viewModel: ResourceErrorViewModel.noError)
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with resource: Resource) {
        do {
            resourceView.display(viewModel: try mapper(resource))
            loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
        } catch {
            didFinishLoading(with: error)
        }
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(viewModel: ResourceErrorViewModel.error(message: Self.loadError))
        loadingView.display(viewModel: ResourceLoadingViewModel(isLoading: false))
    }
}
