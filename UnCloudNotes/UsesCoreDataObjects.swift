//
//  UsesCoreDataObjects.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 2/1/21.
//  Copyright © 2021 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData

protocol UsesCoreDataObjects: class {
    var managedObjectContext: NSManagedObjectContext? { get set }
}
