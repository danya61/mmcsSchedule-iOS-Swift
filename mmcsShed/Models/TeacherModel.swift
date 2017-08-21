//
//  TeacherModel.swift
//  mmcsShed
//
//  Created by Danya on 21.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import SwiftyJSON
import Foundation

struct TeacherModel {
	let id: Int
	let name: String
	let degree: String
	
	init(with json: JSON) {
		self.id = Int(json["id"].stringValue)!
		self.name = json["name"].stringValue
		self.degree = json["degree"].stringValue
	}
	
}
