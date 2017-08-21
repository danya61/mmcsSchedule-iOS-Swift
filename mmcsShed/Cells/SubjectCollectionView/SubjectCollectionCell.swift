//
//  SubjectCollectionCell.swift
//  mmcsShed
//
//  Created by Danya on 11.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import UIKit

class SubjectCollectionCell: UICollectionViewCell {
	
	@IBOutlet weak var timeSince: UILabel!
	@IBOutlet weak var timeUntil: UILabel!
	@IBOutlet weak var subjectName: UILabel!
	@IBOutlet weak var teacherName: UILabel!
	@IBOutlet weak var room: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		configureShadow()
	}
	
	func configure(timeS: String, timeU: String, sbjName: String, tchName: String, roomS: String) {
		timeSince.text = timeS
		timeUntil.text = timeU
		subjectName.text = sbjName
		teacherName.text = tchName
		room.text = roomS
	}
	
	fileprivate func configureShadow() {
		self.layer.borderColor = UIColor(hex: "DBDBDB").cgColor
		self.layer.borderWidth = 1.0
		
		
		self.contentView.layer.cornerRadius = 8.0
		self.contentView.layer.borderWidth = 1.0
		self.contentView.layer.borderColor = UIColor.clear.cgColor
		self.contentView.layer.masksToBounds = true
		
		self.layer.cornerRadius = 8.0
		self.layer.shadowColor = UIColor(hex: "000", alpha: 0.11).cgColor
		self.layer.shadowOffset = CGSize(width: 0, height: 6.0)
		self.layer.shadowRadius = 5.0
		self.layer.shadowOpacity = 1.0
		self.layer.masksToBounds = false
		drawBezierPath()
	}
	
	fileprivate func drawBezierPath() {
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 12 + timeSince.frame.size.width , y: 0))
		path.addLine(to: CGPoint(x: 12 + timeSince.frame.size.width, y: self.frame.size.height))
		
		let shapeLayer = CAShapeLayer()
		shapeLayer.path = path.cgPath
		shapeLayer.strokeColor = UIColor.red.cgColor
		shapeLayer.lineWidth = 4.0
		self.layer.addSublayer(shapeLayer)
	}

	
}
