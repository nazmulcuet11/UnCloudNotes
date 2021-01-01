//
//  ImageAttachment.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 31/12/20.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ImageAttachment: Attachment {
    @NSManaged var caption: String
    @NSManaged var width: Float
    @NSManaged var height: Float
    @NSManaged var image: UIImage?
}
