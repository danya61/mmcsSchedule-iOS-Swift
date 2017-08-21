//
//  FridayLessons+CoreDataProperties.swift
//  
//
//  Created by Danya on 13.05.17.
//
//

import Foundation
import CoreData


extension FridayLessons {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FridayLessons> {
        return NSFetchRequest<FridayLessons>(entityName: "FridayLessons");
    }

    @NSManaged public var room: String?
    @NSManaged public var subjectName: String?
    @NSManaged public var teacherName: String?
    @NSManaged public var timeBefore: String?
    @NSManaged public var timeSince: String?
    @NSManaged public var isUpper: Int32

}
