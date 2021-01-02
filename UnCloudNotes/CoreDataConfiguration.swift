//
//  CoreDataConfiguration.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataConfiguration {
    static let storeType = NSSQLiteStoreType

    static let storeName = "UnCloudNotesDataModel"

    static let schemaName = "UnCloudNotesDataModel"

    static let modelDirectory: String = "\(schemaName).momd"

    static let storeURL: URL = {
        let storePaths = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true)
        let storePath = storePaths[0] as NSString
        let fileManager = FileManager.default

        do {
            try fileManager.createDirectory(
                atPath: storePath as String,
                withIntermediateDirectories: true,
                attributes: nil)
        } catch {
            print("Error creating storePath \(storePath): \(error)")
        }

        let sqliteFilePath = storePath
            .appendingPathComponent(storeName + ".sqlite")
        return URL(fileURLWithPath: sqliteFilePath)
    }()
}
