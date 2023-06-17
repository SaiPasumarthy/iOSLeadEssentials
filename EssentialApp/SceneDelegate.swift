//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Sai Pasumarthy on 04/06/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        let client = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: client)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: client)
        
        let localStore = try! CoreDataFeedStore.init(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, timestamp: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(localStore)
        
        let feedViewController = FeedUIComposer.feedComposedWith(
            feedLoader:FeedLoaderWithFallbackComposite(
                primary: FeedLoaderCacheDecorator(
                    decoratee: remoteFeedLoader,
                    cache: localFeedLoader),
                fallback: localFeedLoader),
            imageLoader: FeedImageDataLoaderWithFallbackComposite(
                primary: localImageLoader,
                fallback: FeedImageDataLoaderCacheDecorator(
                    decoratee: remoteImageLoader,
                    cache: localImageLoader))
        )
        window?.rootViewController = feedViewController
    }

    func makeRemoteClient() -> HTTPClient {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}
