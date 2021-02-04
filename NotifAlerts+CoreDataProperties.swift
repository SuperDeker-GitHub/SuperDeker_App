//
//  NotifAlerts+CoreDataProperties.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 1/12/21.
//
//

import Foundation
import CoreData


extension NotifAlerts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NotifAlerts> {
        return NSFetchRequest<NotifAlerts>(entityName: "NotifAlerts")
    }

    @NSManaged public var contentImage: Data?
    @NSManaged public var contentText: String?
    @NSManaged public var contentType: Int64
    @NSManaged public var startDate: Date?
    @NSManaged public var title: String?

}

extension NotifAlerts : Identifiable {

}
