//
//  CoreDataManager.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager {

    let storeType: String = CoreDataConfiguration.storeType
    let schemaName: String = CoreDataConfiguration.schemaName
    let storeName: String = CoreDataConfiguration.storeName
    let storeURL: URL = CoreDataConfiguration.storeURL

    private let migrator: CoreDataMigrator = CoreDataMigrator()

    private(set) lazy var storeDescription: NSPersistentStoreDescription = {
        let description = NSPersistentStoreDescription(url: self.storeURL)
        description.shouldMigrateStoreAutomatically = false
        description.shouldInferMappingModelAutomatically = false
        description.type = storeType
        return description
    }()

    private(set) lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: schemaName)
        container.persistentStoreDescriptions = [storeDescription]
        return container
    }()

    lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }()

    lazy var mainContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        context.automaticallyMergesChangesFromParent = true
        return context
    }()


    // MARK: - setup

    func setup(completion: @escaping () -> Void) {
        loadPersistentStore {
            completion()
        }
    }

    func saveContext () {
        guard mainContext.hasChanges else { return }

        do {
            try mainContext.save()
        } catch let error as NSError {
            fatalError("Unresolved error \(error), \(error.userInfo)")
        }
    }

    // MARK: - Helpers

    private func loadPersistentStore(completion: @escaping () -> Void) {
        migrateStoreIfNeeded {
            self.persistentContainer.loadPersistentStores {
                (storeDescription, error) in

                if let error = error {
                    fatalError("Unable to load persistent store \(error)")
                }

                completion()
            }
        }
    }

    private func migrateStoreIfNeeded(completion: @escaping () -> Void) {
        if migrator.requiresMigrationForStore(at: storeURL, to: .latest) {
            let queue = DispatchQueue.global(qos: .userInitiated)
            queue.async {
                self.migrator.migrateStore(at: self.storeURL, to: .latest)

                DispatchQueue.main.async {
                    completion()
                }
            }
        } else {
            completion()
        }
    }
}
