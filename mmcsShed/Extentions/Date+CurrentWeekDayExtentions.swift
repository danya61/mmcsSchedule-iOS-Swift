//
//  Date+CurrentWeekDayExtentions.swift
//  mmcsShed
//
//  Created by Danya on 11.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import Foundation

extension Date {
	
	func dayNumberOfWeek() -> Int? {
		return Calendar.current.dateComponents([.weekday], from: self).weekday
	}
	
	func dayOfWeek() -> String? {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "EEEE"
		return dateFormatter.string(from: self).capitalized
	}
	
}
