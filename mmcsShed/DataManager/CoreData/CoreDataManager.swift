//
//  CoreDataManager.swift
//  mmcsShed
//
//  Created by Danya on 10.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import Foundation
import CoreData

enum WeekDays: Int {
	case MondayLessons
  case TuesdayLessons
	case WednesdayLessons
	case ThursdayLessons
	case FridayLessons
	case SaturdayLessons
	
	var string: String {
		return String(describing: self)
	}
	
}

class CoreDataManager {

	fileprivate var context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
	
	init() {
		context = CoreData.sharedInstance.managedObjectContext
	}
	
	
	func saveModel(with row: Int, lessonModel: LessonModel) {
		let entityValue = WeekDays(rawValue: row)?.string
		let entityDescription = NSEntityDescription.entity(forEntityName: entityValue!, in: context)
		var model: NSManagedObject?
		switch row {
		case 0:
			model = MondayLessons(entity: entityDescription!, insertInto: context)
		case 1:
			model = TuesdayLessons(entity: entityDescription!, insertInto: context)
		case 2:
			model = WednesdayLessons(entity: entityDescription!, insertInto: context)
		case 3:
			model = ThursdayLessons(entity: entityDescription!, insertInto: context)
		case 4:
			model = FridayLessons(entity: entityDescription!, insertInto: context)
		case 5:
			model = SaturdayLessons(entity: entityDescription!, insertInto: context)
		default:
			break
		}
		
		model?.setValue(lessonModel.room, forKey: "room")
		model?.setValue(lessonModel.subjectName, forKey: "subjectName")
		model?.setValue(lessonModel.teacherName, forKey: "teacherName")
		model?.setValue(lessonModel.timeBefore, forKey: "timeBefore")
		model?.setValue(lessonModel.timeSince, forKey: "timeSince")
		model?.setValue(lessonModel.isUpper, forKey: "isUpper")
		
		do {
			try context.save()
		} catch let error as NSError {
			NSLog("Unresolved error \(error), \(error.userInfo)")
		}
	}
	
	func fetchForModel(with row: Int, indexPath: Int) -> NSManagedObject? {
		let entityValue = WeekDays(rawValue: row)?.string
		print(entityValue)
		let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: entityValue!)
		do {
			let result = try context.fetch(fetchReq)
			guard result.count != 0 else { return nil }
			
			return result[indexPath] as? NSManagedObject
		} catch let error as NSError {
			NSLog("Could not fetch \(error), \(error.userInfo)")
		}
		return nil
	}
	
	func deleteEntities() {
		for row in 0...5 {
			let entityValue = WeekDays(rawValue: row)?.string
			let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityValue!)
			do {
				let result = try context.fetch(fetchRequest)
				if result.count == 0 {
					print("Nothing to delete on row - ", row)
				} else {
					switch row {
					case 0:
						for manageObject in result {
							context.delete(manageObject as! MondayLessons)
						}
					case 1:
						for manageObject in result {
							context.delete(manageObject as! TuesdayLessons)
						}
					case 2:
						for manageObject in result {
							context.delete(manageObject as! WednesdayLessons)
						}
					case 3:
						for manageObject in result {
							context.delete(manageObject as! ThursdayLessons)
						}
					case 4:
						for manageObject in result {
							context.delete(manageObject as! FridayLessons)
						}
					case 5:
						for manageObject in result {
							context.delete(manageObject as! SaturdayLessons)
						}
					default:
						break
					}
				}
			} catch let error as NSError {
				NSLog("Could not fetch \(error), \(error.userInfo)")
			}
		}
	}
	
	func countEntity(with row: Int) -> Int {
		let entityValue = WeekDays(rawValue: row)?.string
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityValue!)
		do {
			let result = try context.fetch(fetchRequest)
			return result.count
		} catch let error as NSError {
			NSLog("Could not fetch \(error), \(error.userInfo)")
		}
		
		return 0
	}

	
	
	
}
