//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Sai Pasumarthy on 17/03/23.
//

import CoreData

extension NSPersistentContainer {
    static func load(name: String, model: NSManagedObjectModel, url: URL) throws -> NSPersistentContainer {
        let description = NSPersistentStoreDescription(url: url)
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        var loadingError: Swift.Error?
        container.loadPersistentStores { loadingError = $1 }
        try loadingError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func with(name: String, in bundle: Bundle) -> NSManagedObjectModel? {
        return bundle
            .url(forResource: name, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
