//
//  CoreDataMigrator.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

class CoreDataMigrator {
    func requiresMigrationForStore(at storeURL: URL, to targetVersion: CoreDataSchemaVersion) -> Bool {
        let metadata = NSPersistentStoreCoordinator.metadataForStore(at: storeURL)
        let compatibleVersion = CoreDataSchemaVersion.compatibleVersionForStoreMetadata(metadata)
        return compatibleVersion != targetVersion
    }

    func migrateStore(at storeURL: URL, to targetVersion: CoreDataSchemaVersion) {
        forceWALCheckpointingForStore(at: storeURL)

        var currentStoreURL = storeURL
        let migrationSteps = migrationStepsForStore(at: storeURL, to: targetVersion)

        for migrationStep in migrationSteps {
            let manager = NSMigrationManager(sourceModel: migrationStep.source, destinationModel: migrationStep.destination)
            let destinationURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(UUID().uuidString)

            do {
                try manager.migrateStore(
                    from: currentStoreURL,
                    sourceType: NSSQLiteStoreType,
                    options: nil,
                    with: migrationStep.mapping,
                    toDestinationURL: destinationURL,
                    destinationType: NSSQLiteStoreType,
                    destinationOptions: nil
                )

            } catch {
                fatalError("Failed attempting to migrate from \(migrationStep.source) to \(migrationStep.destination), error: \(error)")
            }

            // Destroy intermediate step's store, keep the original storeURL
            if currentStoreURL != storeURL {
                NSPersistentStoreCoordinator.destroyStore(at: currentStoreURL)
            }

            currentStoreURL = destinationURL
        }

        NSPersistentStoreCoordinator.replaceStore(at: storeURL, withStoreAt: currentStoreURL)

        if currentStoreURL != storeURL {
            NSPersistentStoreCoordinator.destroyStore(at: currentStoreURL)
        }
    }

    // MARK: - Helpers

    private func forceWALCheckpointingForStore(at storeURL: URL) {
        let metadata = NSPersistentStoreCoordinator.metadataForStore(at: storeURL)
        guard let compatibleModel = NSManagedObjectModel.compatibleModelForStoreMetadata(metadata) else {
            return
        }

        do {
            let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: compatibleModel)
            let options = [NSSQLitePragmasOption: ["journal_mode": "DELETE"]]
            let store = persistentStoreCoordinator.addPersistentStore(at: storeURL, options: options)
            try persistentStoreCoordinator.remove(store)
        } catch {
            fatalError("Failed to force WAL checkpointing, error: \(error)")
        }
    }

    private func migrationStepsForStore(at storeURL: URL, to targetVersion: CoreDataSchemaVersion) -> [CoreDataMigrationStep] {

        let metadata = NSPersistentStoreCoordinator.metadataForStore(at: storeURL)
        guard let sourceVersion = CoreDataSchemaVersion.compatibleVersionForStoreMetadata(metadata) else {
            fatalError("Unknown store version at URL \(storeURL)")
        }

        return migrationSteps(from: sourceVersion, to: targetVersion)
    }

    private func migrationSteps(from sourceVersion: CoreDataSchemaVersion, to targetVersion: CoreDataSchemaVersion) -> [CoreDataMigrationStep] {

        var sourceVersion = sourceVersion
        var migrationSteps = [CoreDataMigrationStep]()

        while sourceVersion != targetVersion, let nextVersion = sourceVersion.next {
            let migrationStep = CoreDataMigrationStep(sourceVersion: sourceVersion, destinationVersion: nextVersion)
            migrationSteps.append(migrationStep)

            sourceVersion = nextVersion
        }

        return migrationSteps
    }
 }
