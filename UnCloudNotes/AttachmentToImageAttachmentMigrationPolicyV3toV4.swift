//
//  AttachmentToImageAttachmentMigrationPolicyV3toV4.swift
//  UnCloudNotes
//
//  Created by Nazmul Islam on 31/12/20.
//  Copyright © 2020 Ray Wenderlich. All rights reserved.
//

import Foundation
import CoreData
import UIKit

let errorDomain = "Migration"

class AttachmentToImageAttachmentMigrationPolicyV3toV4: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager) throws {

        // 1 create a destination object, source object is supplied(sInstance)
        // ImageAttachment(context: NSManagedObjectContext) initializer can't be used
        // as it will simply crash, because it depends on the model having been loaded
        // and finalized, which hasn’t happened halfway through a migration
        let description = NSEntityDescription.entity(
            forEntityName: "ImageAttachment",
            in: manager.destinationContext
        )
        let newAttachment = ImageAttachment(
            entity: description!,
            insertInto: manager.destinationContext
        )

        // 2 apply mappings defined in corresponding .xcmappingmodel file
        try traversePropertyMappings(entityMapping: mapping) {
            (propertyMapping, destinationName) in

            if let valueExpression = propertyMapping.valueExpression {
                let context: NSMutableDictionary = ["source": sInstance]
                guard let destinationValue = valueExpression.expressionValue(
                        with: sInstance,
                        context: context
                ) else {
                    return
                }

                newAttachment.setValue(destinationValue, forKey: destinationName)
            }
        }

        // 3 apply custom mappings
        if let image = sInstance.value(forKey: "image") as? UIImage {
            newAttachment.setValue(image.size.width, forKey: "width")
            newAttachment.setValue(image.size.height, forKey: "height")
        }
        let body = (sInstance.value(forKeyPath: "note.body") as? NSString) ?? ""
        newAttachment.setValue(body.substring(to: 80), forKey: "caption")

        // 4 pass the destination object to the migration manager
        manager.associate(sourceInstance: sInstance,
                          withDestinationInstance: newAttachment,
                          for: mapping)
    }

    private func traversePropertyMappings(
        entityMapping: NSEntityMapping,
        block: (NSPropertyMapping, String) -> Void) throws {

        if let attributeMappings = entityMapping.attributeMappings {
            for propertyMapping in attributeMappings {
                if let destinationName = propertyMapping.name {
                    block(propertyMapping, destinationName)
                } else {
                    let message = "Attribute destination not configured properly"
                    let userInfo = [NSLocalizedFailureReasonErrorKey: message]
                    throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
                }
            }
        } else {
            let message = "No attribute mappings found!"
            let userInfo = [NSLocalizedFailureReasonErrorKey: message]
            throw NSError(domain: errorDomain, code: 0, userInfo: userInfo)
        }
    }
}
