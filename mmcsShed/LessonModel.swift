//
//  Models.swift
//  mmcsShed
//
//  Created by Danya on 10.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import Foundation

class LessonModel {
	
	let timeSince: String
	let timeBefore: String
	let isUpper: Int
	let room: String
	let teacherName: String
	let subjectName: String
	
	init(timeSince: String, timeBefore: String, room: String, teacherName: String, subjectName: String, isUp: Int) {
		self.timeSince = timeSince
		self.timeBefore = timeBefore
		self.room = room
		self.isUpper = isUp
		self.teacherName = teacherName
		self.subjectName = subjectName
	}
	
}

class LessonTeacherModel: LessonModel {
	var dayOfWeek: Int
	
	init(timeSince: String,
	     timeBefore: String,
	     room: String,
	     teacherName: String,
	     subjectName: String,
	     isUp: Int,
	     dayOfWeek: Int) {
		self.dayOfWeek = dayOfWeek
		super.init(timeSince: timeSince,
		           timeBefore: timeBefore,
		           room: room,
		           teacherName: teacherName,
		           subjectName: subjectName,
		           isUp: isUp)
	}
}
