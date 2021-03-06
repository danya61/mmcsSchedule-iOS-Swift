//
//  TuesdayLessons+CoreDataProperties.swift
//  
//
//  Created by Danya on 13.05.17.
//
//

import Foundation
import CoreData


extension TuesdayLessons {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TuesdayLessons> {
        return NSFetchRequest<TuesdayLessons>(entityName: "TuesdayLessons");
    }

    @NSManaged public var room: String?
    @NSManaged public var subjectName: String?
    @NSManaged public var teacherName: String?
    @NSManaged public var timeBefore: String?
    @NSManaged public var timeSince: String?
    @NSManaged public var isUpper: Int32

}
