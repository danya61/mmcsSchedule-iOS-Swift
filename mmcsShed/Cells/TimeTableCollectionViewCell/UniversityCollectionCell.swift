//
//  UniversityCollectionCell.swift
//  mmcsShed
//
//  Created by Danya on 09.07.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import UIKit

class UniversityCollectionCell: UICollectionViewCell {
	@IBOutlet weak var inputTextfield: UITextField!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
	}
	
	func configure(row: Int) {
		switch row {
		case 0:
			inputTextfield.placeholder = "Курс"
		case 1:
			inputTextfield.placeholder = "Группа"
			self.backgroundColor = .red
		case 2:
			inputTextfield.placeholder = "Степень"
			self.backgroundColor = .green
		default:
			break
		}
	}
	
	
}
