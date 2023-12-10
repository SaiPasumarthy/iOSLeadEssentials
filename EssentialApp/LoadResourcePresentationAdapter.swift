//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Sai Pasumarthy on 15/04/23.
//

import EssentialFeediOS
import EssentialFeed
import Combine

final class LoadResourcePresentationAdapter<Resource, View: ResourceView> {
    private var cancellable: Cancellable?
    private let loader: () -> AnyPublisher<Resource, Error>
    private var isLoading: Bool = false
    
    var presenter: LoadResourcePresenter<Resource, View>?
    
    init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        guard !isLoading else { return }
        
        presenter?.didStartLoading()
        isLoading = true
        
        cancellable = loader()
            .dispatchOnMainQueue()
            .handleEvents(receiveCancel: { [weak self] in
                self?.isLoading = false
            })
            .sink { [weak self] completion in
                switch completion {
                case .finished: break
                    
                case let .failure(error):
                    self?.presenter?.didFinishLoading(with: error)
                }
                
                self?.isLoading = false
            } receiveValue: { [weak self] resource in
                self?.presenter?.didFinishLoading(with: resource)
            }
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    func didCancelRequestImage() {
        cancellable?.cancel()
        cancellable = nil
    }
}
