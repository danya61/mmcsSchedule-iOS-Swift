//
//  DataService.swift
//  mmcsShed
//
//  Created by Danya on 22.04.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import Alamofire
import AlamofireObjectMapper
import Foundation
import SwiftyJSON

final class DataService {
	
	fileprivate let currentWeekURL = "http://users.mmcs.sfedu.ru:3000/APIv0/time/week"
	fileprivate let gradeListURL = "http://users.mmcs.sfedu.ru:3000/APIv0/group/list"
	fileprivate let scheduleListGroup = "http://users.mmcs.sfedu.ru:3000/APIv0/schedule/group"
	fileprivate let scheduleListTeacher = "http://users.mmcs.sfedu.ru:3000/APIv1/schedule/teacher"
	fileprivate let teacherListURL = "http://users.mmcs.sfedu.ru:3000/APIv0/teacher/list"
	fileprivate let gradeList = "http://users.mmcs.sfedu.ru:3000/APIv1/grade/list"
	
	fileprivate lazy var coreDataManager: CoreDataManager = {
		return CoreDataManager()
	}()
	
	///проверяем, правильно ли введены данные пользователем 
	/// -author: Danya Vorobyev
	func checkUserInfo(step: String, kourse: Int, group: Int, complition: @escaping ((Bool) -> Void)) {
		Alamofire
		.request(gradeList, method: .get, encoding: JSONEncoding.default)
		.validate()
		.responseJSON { response in
			switch response.result {
			case .success(let result):
				let jsonResult = JSON(result)
				var isResult = false
				for item in jsonResult {
					if item.1["degree"].stringValue == step && item.1["num"].intValue == kourse {
						isResult = true
						let id = item.1["id"].intValue
						self.checkUserGroup(group: group, kourse: id, complite: { (isHaveGroup) in
							complition(isHaveGroup)
						})
					}
				}
				if !isResult {
					complition(false)
				}
			case .failure:
				complition(false)
			}
		}
	}
	
	private func checkUserGroup(group: Int, kourse: Int, complite: @escaping ((Bool) -> Void)) {
		let url = gradeListURL + "/" + "\(kourse)"
		Alamofire
			.request(url, method: .get, encoding: JSONEncoding.default)
			.validate()
			.responseJSON { response in
				switch response.result {
				case .success(let result):
					let jsonResult = JSON(result)
					var isResult = false
					print("json result = ",jsonResult)
					for item in jsonResult {
						let num = item.1["num"].intValue
						if num == group {
							isResult = true
							complite(true)
							break
						}
					}
					if !isResult {
						complite(false)
					}
				case .failure:
					complite(false)
				}
		}

	}
	
	///получаем id для получения расписания группы, после чего вызываем
	/// - Author: Danya Vorobyev
	func requestOfGradeList(with kourse: Int, group: Int, complition: @escaping (() -> Void)) {
		let url = gradeListURL + "/" + String(kourse)
		var id = -1
		Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
		.validate()
		.responseJSON { response in
			switch response.result {
			case .success(let result):
				let jsonResult = JSON(result)
				for usingItem in jsonResult {
					if usingItem.1["num"].intValue == group {
						id = usingItem.1["id"].intValue
						self.requestScheduleOfGroup(with: id) {
							complition()
						}
					}
				}
			case .failure(let error):
				if let statusCode = response.response?.statusCode {
					print(error, " ", statusCode)
					complition()
				}
			}
		}

	}

	///получаем расписание группы
	///author: Danya Vorobyev
	func requestScheduleOfGroup(with id: Int, complition: @escaping (() -> Void)) {
		let url = scheduleListGroup + "/" + String(id)
		Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
		.validate()
		.responseJSON { response in
			switch response.result {
			case .success(let result):
				let jsonRes = JSON(result)
				print(jsonRes)
				self.coreDataManager.deleteEntities()
				let jsonCurricula = jsonRes["curricula"]
				let jsonLessons = jsonRes["lessons"]
				var curriculaArray = [CurriculaServerModel]()
				var lessonsArray = [LessonServerModel]()
				for (_, item) in jsonCurricula {
					let localModel = CurriculaServerModel(with: item)
					curriculaArray.append(localModel)
				}
				
				for (_, item) in jsonLessons {
					let localModel = LessonServerModel(with: item)
					lessonsArray.append(localModel)
				}
				for item in lessonsArray {
					item.timeslot.remove(at: item.timeslot.index(before: item.timeslot.endIndex))
					item.timeslot.remove(at: item.timeslot.startIndex)
					let timeslotArray = item.timeslot.components(separatedBy: ",")
					guard timeslotArray.count == 4 else { return }
					var timeSince = timeslotArray[1]
					let dayOfWeek = timeslotArray[0]
					var timeUntil = timeslotArray[2]
					let upperLowerWeek = timeslotArray[3]
					var teacherName: String!
					var subjectName: String!
					var roomName: String!
					for cur in curriculaArray {
						if item.id == cur.lessonId {
							teacherName = cur.teacherName
							subjectName = cur.subjectName
							roomName = cur.roomName
						}
					}
					let timeSinceArray = timeSince.components(separatedBy: ":")
					timeSince = timeSinceArray[0] + ":" + timeSinceArray[1]
					let timeUntilArray = timeUntil.components(separatedBy: ":")
					timeUntil = timeUntilArray[0] + ":" + timeUntilArray[1]
					var isUp: Int?
					switch upperLowerWeek {
					case "full":
						isUp = 2
					case "upper":
						isUp = 0
					case "lower":
						isUp = 1
					default:
						break
					}
					let sheduleLesson = LessonModel(timeSince: timeSince ?? "",
					                                timeBefore: timeUntil ?? "",
					                                room: roomName ?? "",
					                                teacherName: teacherName ?? "",
					                                subjectName: subjectName ?? "",
					                                isUp: isUp ?? 2)
					self.coreDataManager.saveModel(with: Int(dayOfWeek)!, lessonModel: sheduleLesson)
				}
				complition()
			case .failure(let error):
				if let statusCode = response.response?.statusCode {
					print(error, " ", statusCode)
					complition()
				}
			}
		}
	}
	
	///получаем расписание группы
	///author: Danya Vorobyev
	func requestScheduleOfTeacher(with id: Int, complition: @escaping (([LessonTeacherModel]) -> Void)) {
		let url = scheduleListTeacher + "/" + String(id)
		Alamofire.request(url, method: .get, encoding: JSONEncoding.default)
			.validate()
			.responseJSON { response in
				switch response.result {
				case .success(let result):
					let jsonRes = JSON(result)
					print(jsonRes)
					let jsonCurricula = jsonRes["curricula"]
					let jsonLessons = jsonRes["lessons"]
					var curriculaArray = [CurriculaServerModel]()
					var lessonsArray = [LessonServerModel]()
					for (_, item) in jsonCurricula {
						let localModel = CurriculaServerModel(with: item)
						curriculaArray.append(localModel)
					}
					
					for (_, item) in jsonLessons {
						let localModel = LessonServerModel(with: item)
						lessonsArray.append(localModel)
					}
					var lessons = [LessonTeacherModel]()
					for item in lessonsArray {
						item.timeslot.remove(at: item.timeslot.index(before: item.timeslot.endIndex))
						item.timeslot.remove(at: item.timeslot.startIndex)
						let timeslotArray = item.timeslot.components(separatedBy: ",")
						guard timeslotArray.count == 4 else { return }
						var timeSince = timeslotArray[1]
						let dayOfWeek = timeslotArray[0]
						var timeUntil = timeslotArray[2]
						let upperLowerWeek = timeslotArray[3]
						var teacherName: String = ""
						var subjectName: String = ""
						var roomName: String = ""
						for cur in curriculaArray {
							if item.id == cur.lessonId {
								teacherName = cur.teacherName
								subjectName = cur.subjectName
								roomName = cur.roomName
							}
						}
						let timeSinceArray = timeSince.components(separatedBy: ":")
						timeSince = timeSinceArray[0] + ":" + timeSinceArray[1]
						let timeUntilArray = timeUntil.components(separatedBy: ":")
						timeUntil = timeUntilArray[0] + ":" + timeUntilArray[1]
						var isUp: Int?
						switch upperLowerWeek {
						case "full":
							isUp = 2
						case "upper":
							isUp = 0
						case "lower":
							isUp = 1
						default:
							break
						}
						let sheduleLesson = LessonTeacherModel(timeSince: timeSince,
						                                       timeBefore: timeUntil,
						                                       room: roomName,
						                                       teacherName: teacherName,
						                                       subjectName: subjectName,
						                                       isUp: isUp!,
						                                       dayOfWeek: Int(dayOfWeek)!)
						lessons.append(sheduleLesson)
					}
					complition(lessons)
				case .failure(let error):
					if let statusCode = response.response?.statusCode {
						print(error, " ", statusCode)
						complition([LessonTeacherModel]())
					}
				}
		}
	}
	
	///получаем текущую неделю
	///author: Danya Vorobyev
	func requestCurrentWeek(complition: @escaping ((Int) -> Void)) {
		Alamofire.request(currentWeekURL, method: .get, encoding: JSONEncoding.default)
		.validate()
		.responseJSON { response in
			switch response.result {
			case .success(let res):
				let jsonRes = JSON(res)
				let type = jsonRes["type"].intValue
				complition(type)
			case .failure(let error):
				print("error current week = ", error.localizedDescription)
				complition(-1)
			}
		}
	}
	
	///получаем список преподавателей
	///author: Danya Vorobyev
	func requestListOfTeachers(complition: @escaping (([TeacherModel]) -> Void)) {
		Alamofire.request(teacherListURL, method: .get, encoding: JSONEncoding.default)
		.validate()
		.responseJSON { (response) in
			switch response.result {
			case .success(let teachers):
				let downloadGroup = DispatchGroup()
				let jsonTeachers = JSON(teachers)
				var teachers: [TeacherModel] = []
				for item in jsonTeachers {
					downloadGroup.enter()
					let temp_teacher = TeacherModel(with: item.1)
					teachers.append(temp_teacher)
					downloadGroup.leave()
				}
				downloadGroup.notify(queue: .main, execute: { 
					complition(teachers)
				})
			case .failure(let error):
				print("Error requesting schedule of teachers: ", error)
			}
			
			
		}
		
	}
	
}
