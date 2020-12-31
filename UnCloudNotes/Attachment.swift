//
//  Attachment.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 31/12/20.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class Attachment: NSManagedObject {
    @NSManaged var image: UIImage?
    @NSManaged var dateCreated: Date
    @NSManaged var note: Note?
    
}
