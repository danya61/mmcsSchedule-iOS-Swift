//
//  CurriculaServerModel.swift
//  mmcsShed
//
//  Created by Danya on 10.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import SwiftyJSON
import Foundation

struct CurriculaServerModel {
	
	var roomid: Int
	var teacherDegree: String
	var id: Int
	var subjectId: Int
	var roomName: String
	var lessonId: Int
	var teacherId: Int
	var subjectAbbr: String
	var teacherName: String
	var subjectName: String
	
	init(with json: JSON) {
		self.roomid = json["roomid"].intValue
		self.teacherDegree = json["teacherdegree"].stringValue
		self.id = json["id"].intValue
		self.subjectId = json["subjectid"].intValue
		self.roomName = json["roomname"].stringValue
		self.lessonId = json["lessonid"].intValue
		self.teacherId = json["teacherid"].intValue
		self.subjectAbbr = json["subjectabbr"].stringValue
		self.teacherName = json["teachername"].stringValue
		self.subjectName = json["subjectname"].stringValue
	}
	
	
}
