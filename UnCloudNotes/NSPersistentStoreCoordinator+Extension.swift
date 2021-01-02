//
//  NSPersistentStoreCoordinator+Extension.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

extension NSPersistentStoreCoordinator {
    func addPersistentStore(at storeURL: URL, options: [AnyHashable : Any]) -> NSPersistentStore {
        do {
            return try addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: options)
        } catch let error {
            fatalError("failed to add persistent store to coordinator, error: \(error)")
        }
    }

    static func metadataForStore(at storeURL: URL) -> [String: Any] {
        let metadata: [String: Any]
        do {
            metadata = try NSPersistentStoreCoordinator
                .metadataForPersistentStore(ofType: NSSQLiteStoreType, at: storeURL, options: nil)
        } catch {
            metadata = [:]
            print("Error retrieving metadata for store at URL: \(storeURL), error: \(error)")
        }
        return metadata
    }

    static func destroyStore(at storeURL: URL) {
        do {
            let model = NSManagedObjectModel()
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            try persistentStoreCoordinator.destroyPersistentStore(at: storeURL, ofType: NSSQLiteStoreType, options: nil)
        } catch {
            fatalError("Failed to destroy store at \(storeURL), error: \(error)")
        }
    }

    static func replaceStore(at targetURL: URL, withStoreAt sourceURL: URL) {
        do {
            let model = NSManagedObjectModel()
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
            try persistentStoreCoordinator.replacePersistentStore(at: targetURL, destinationOptions: nil, withPersistentStoreFrom: sourceURL, sourceOptions: nil, ofType: NSSQLiteStoreType)
        } catch {
            fatalError("Failed to replace store at \(targetURL) with \(sourceURL), error: \(error)")
        }
    }
}

