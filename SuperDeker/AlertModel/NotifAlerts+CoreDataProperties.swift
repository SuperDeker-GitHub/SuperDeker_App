//
//  NotifAlerts+CoreDataProperties.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 1/11/21.
//
//

import Foundation
import CoreData


extension NotifAlerts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotifAlerts> {
        return NSFetchRequest<NotifAlerts>(entityName: "NotifAlerts")
    }

    @NSManaged public var title: String?
    @NSManaged public var contentText: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var contentType: Int64
    @NSManaged public var contentImage: Data?

}

extension NotifAlerts : Identifiable {

}
