//
//  LSPet+CoreDataProperties.swift
//  FindYourOnlys
//
//  Created by 鄭昭韋 on 2022/4/20.
//
//

import Foundation
import CoreData

extension LSPet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LSPet> {
        return NSFetchRequest<LSPet>(entityName: "LSPet")
    }

    @NSManaged public var address: String
    @NSManaged public var age: String
    @NSManaged public var bacterin: String
    @NSManaged public var bodyType: String
    @NSManaged public var closedDate: String
    @NSManaged public var color: String
    @NSManaged public var createdDate: String
    @NSManaged public var favoriteID: String
    @NSManaged public var foundPlace: String
    @NSManaged public var id: Int64
    @NSManaged public var kind: String
    @NSManaged public var location: String
    @NSManaged public var openDate: String
    @NSManaged public var photoURLString: String
    @NSManaged public var remark: String
    @NSManaged public var sex: String
    @NSManaged public var status: String
    @NSManaged public var sterilization: String
    @NSManaged public var telephone: String
    @NSManaged public var updatedDate: String
    @NSManaged public var userID: String
    @NSManaged public var variety: String
    @NSManaged public var shelterName: String

}

extension LSPet: Identifiable {

}
