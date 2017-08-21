//
//  LessonServerModel.swift
//  mmcsShed
//
//  Created by Danya on 10.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import SwiftyJSON
import Foundation

class LessonServerModel {
	
	var id: Int
	var subcount: Int
	var uberId: Int
	var timeslot: String
	
//	init(id: Int, subcount: Int, uberId: Int, timeslot: String) {
//		self.id = id
//		self.subcount = subcount
//		self.uberId = uberId
//		self.timeslot = timeslot
//	}
	
	
	init(with json: JSON) {
		self.id = json["id"].intValue
		self.subcount = json["subcount"].intValue
		self.uberId = json["uberid"].intValue
		self.timeslot = json["timeslot"].stringValue
	}
	
	
}
