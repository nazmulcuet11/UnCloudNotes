//
//  CoreDataMigrationStep.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

struct CoreDataMigrationStep {
    let source: NSManagedObjectModel
    let destination: NSManagedObjectModel
    let mapping: NSMappingModel

    init(sourceVersion: CoreDataSchemaVersion, destinationVersion: CoreDataSchemaVersion) {

        let sourceModel = NSManagedObjectModel.model(named: sourceVersion.name)
        let desinationModel = NSManagedObjectModel.model(named: destinationVersion.name)
        let mappingModel = CoreDataMigrationStep.mappingModel(from: sourceModel, to: desinationModel)

        self.source = sourceModel
        self.destination = desinationModel
        self.mapping = mappingModel
    }

    // MARK: - Helpers

    private static func mappingModel(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) -> NSMappingModel {

        var mapping: NSMappingModel?
        if let customMapping = customMappingModel(from: sourceModel, to: destinationModel) {
            mapping = customMapping
        } else if let inferredMapping = inferredMappingModel(from: sourceModel, to: destinationModel)  {
            mapping = inferredMapping
        }

        guard let unwrappedMapping = mapping else {
            fatalError("No custom or inferred mapping model found")
        }

        return unwrappedMapping
    }

    private static func customMappingModel(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) -> NSMappingModel? {

        let model = NSMappingModel(from: [Bundle.main], forSourceModel: sourceModel, destinationModel: destinationModel)
        return model
    }

    private static func inferredMappingModel(from sourceModel: NSManagedObjectModel, to destinationModel: NSManagedObjectModel) -> NSMappingModel? {

        let model = try? NSMappingModel.inferredMappingModel(forSourceModel: sourceModel, destinationModel: destinationModel)
        return model
    }
}

