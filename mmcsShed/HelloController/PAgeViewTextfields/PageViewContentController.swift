//
//  PageViewContentController.swift
//  mmcsShed
//
//  Created by Danya on 17.07.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import UIKit

enum TextfieldValueState: String {
	case stage = "уровень"
	case kourse = "курс"
	case group = "группу"
}

protocol textfieldMainDelegate: class {
	func endEditing(with index: Int?, state: TextfieldValueState)
	func beginEditing()
}

final class PageViewContentController: UIViewController {
	fileprivate var kourseList = ["1", "2", "3", "4"]
	fileprivate var groupList = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
	fileprivate var bakalavrList = ["Бакалавриат", "Магистратура", "Аспирантура"]
	fileprivate var state: TextfieldValueState = .stage
	
	fileprivate lazy var currentEducationInfo: SelectedEducation = {
		return SelectedEducation()
	}()
	var ind: Int = 0
	var koursePickerView: UIPickerView! {
		didSet {
			koursePickerView.delegate = self
			koursePickerView.dataSource = self
		}
	}
	var groupPickerView: UIPickerView! {
		didSet {
			groupPickerView.delegate = self
			groupPickerView.dataSource = self
		}
	}
	var stepPickerView: UIPickerView! {
		didSet {
			stepPickerView.delegate = self
			stepPickerView.dataSource = self
		}
	}
	
	weak var delegate: textfieldMainDelegate!

	
	// ----
	@IBOutlet weak var stepLabel: UILabel!
	@IBOutlet weak var choiceTextfield: UITextField! {
		didSet {
			choiceTextfield.delegate = self
		}
	}
	@IBOutlet weak var heightConstraint: NSLayoutConstraint!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		var stepLabelText = ""
		var stepMutableText = NSMutableAttributedString()
		switch ind {
		case 0:
			stepLabelText = "Шаг 1 из 3"
			state = .stage
			stepPickerView = UIPickerView()
			choiceTextfield.inputView = stepPickerView
		case 1:
			stepLabelText = "Шаг 2 из 3"
			state = .kourse
			koursePickerView = UIPickerView()
			choiceTextfield.inputView = koursePickerView
		case 2:
			stepLabelText = "Шаг 3 из 3"
			state = .group
			groupPickerView = UIPickerView()
			choiceTextfield.inputView = groupPickerView
		default:
			break
		}
		stepMutableText = NSMutableAttributedString(string: stepLabelText,
		                                            attributes: [NSFontAttributeName:UIFont(name: "Georgia-Bold", size: 17.0)!])
		stepMutableText.addAttribute(NSForegroundColorAttributeName,
		                             value: UIColor.gray,
		                             range: NSRange(location: 5,
		                                            length: 5))
		stepLabel.attributedText = stepMutableText
		self.configureTextField()
	}
	
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	func configureTextField() {
		choiceTextfield.placeholder = "Выберите \(state.rawValue)"
		self.choiceTextfield.font = UIFont.boldSystemFont(ofSize: 22)
		self.choiceTextfield.adjustsFontSizeToFitWidth = true
		switch UIDevice().screenType {
		case .iPhone4:
			self.choiceTextfield.font = UIFont.boldSystemFont(ofSize: 18)
			heightConstraint.constant -= 10
		case .iPhone6Plus:
			self.choiceTextfield.font = UIFont.boldSystemFont(ofSize: 25)
			heightConstraint.constant += 36
		case .iPhone6:
			self.choiceTextfield.font = UIFont.boldSystemFont(ofSize: 28)
			heightConstraint.constant += 18
		default:
			break
		}
	}

}

extension PageViewContentController: UITextFieldDelegate {
	func textFieldDidEndEditing(_ textField: UITextField) {
		var index: Int?
		switch state {
		case .group:
			index = currentEducationInfo.group
		case .kourse:
			index = currentEducationInfo.kourse
		case .stage:
			index = currentEducationInfo.step?.rawValue
		}
		delegate.endEditing(with: index, state: self.state)
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		delegate.beginEditing()
		switch state {
		case .group:
			currentEducationInfo.group = 1
			choiceTextfield.text = "1"
		case .kourse:
			currentEducationInfo.kourse = 1
			choiceTextfield.text = "1"
		case .stage:
			currentEducationInfo.step = StepState.bachelor
			choiceTextfield.text = "Бакалавриат"
		}
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return true
	}
}

extension PageViewContentController: UIPickerViewDelegate, UIPickerViewDataSource {
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		switch state {
		case .kourse:
			return kourseList.count
		case .group:
			return groupList.count
		case .stage:
			return bakalavrList.count
		}
		
	}
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return 1
	}
	
	func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
		switch state {
		case .kourse:
			currentEducationInfo.kourse = row + 1
			choiceTextfield.text = kourseList[row]
		case .group:
			currentEducationInfo.group = row + 1
			choiceTextfield.text = groupList[row]
		case .stage:
			currentEducationInfo.step = StepState(rawValue: row)
			choiceTextfield.text = bakalavrList[row]
		}
	}
	
	func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
		switch state {
		case .kourse:
			return kourseList[row]
		case .group:
			return groupList[row]
		case .stage:
			return bakalavrList[row]
		}
	}
	
}
