//
//  NSManagedObjectModel+Extension.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObjectModel {
    class func model(named modelName: String, in bundle: Bundle = .main) -> NSManagedObjectModel {
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "mom", subdirectory: CoreDataConfiguration.modelDirectory) else {
            fatalError("Can not find model url for modelName: \(modelName)")
        }

        guard let model = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Can not instantiate model from URL: \(modelURL)")
        }

        return model
    }

    static func compatibleModelForStoreMetadata(_ metadata: [String: Any]) -> NSManagedObjectModel? {
        if let compatibleVersion = CoreDataSchemaVersion.compatibleVersionForStoreMetadata(metadata) {
            return NSManagedObjectModel.model(named: compatibleVersion.name)
        }
        return nil
    }
}
