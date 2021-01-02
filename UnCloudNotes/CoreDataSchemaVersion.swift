//
//  DataModelVersion.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

enum  CoreDataSchemaVersion: Int, CaseIterable {
    case version1 = 1
    case version2 = 2
    case version3 = 3
    case version4 = 4

    var name: String {
        switch self {
        case .version1:
            return "UnCloudNotesDataModel"
        case .version2:
            return "UnCloudNotesDataModel_v2"
        case .version3:
            return "UnCloudNotesDataModel_v3"
        case .version4:
            return "UnCloudNotesDataModel_v4"
        }
    }

    var next: CoreDataSchemaVersion? {
        switch self {
        case .version1:
            return .version2
        case .version2:
            return .version3
        case .version3:
            return .version4
        case .version4:
            return .version4
        }
    }

    static var latest: CoreDataSchemaVersion {
        return allCases.last!
    }

    static func compatibleVersionForStoreMetadata(_ metadata: [String : Any]) -> CoreDataSchemaVersion? {
        for version in allCases {
            let model = NSManagedObjectModel.model(named: version.name)
            if model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) {
                return version
            }
        }
        return nil
    }
}
