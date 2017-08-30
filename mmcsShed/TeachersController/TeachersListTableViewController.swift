//
//  TeachersListTableViewController.swift
//  mmcsShed
//
//  Created by Danya on 21.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import UIKit

class TeachersListTableViewController: UITableViewController {
	
	fileprivate var timetableIdentifire = "timetable"
	fileprivate var teachersNames = [String]()
	fileprivate var dataService = DataService()
	fileprivate var listOfTeachers: [TeacherModel] = []
	fileprivate var teacherHeader: [String] = []
	fileprivate var filteredHeader: [String] = []
	fileprivate var teacherDict = [String: [String]]()
	fileprivate var filteredDict = [String: [String]]()
	
	fileprivate var resultSearchController: UISearchController! /* = {
		let controller = UISearchController(searchResultsController: nil)
		controller.searchResultsUpdater = self
		controller.dimsBackgroundDuringPresentation = false
		controller.searchBar.sizeToFit()
		controller.searchBar.barTintColor = UIColor.white
		controller.searchBar.delegate = self
		controller.searchBar.backgroundColor = UIColor.clear
		self.tableView.tableHeaderView = controller.searchBar
		return controller
	}() */
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		requestTeachers()
		configureSearchController()
		self.tableView.reloadData()
		let backButton = UIBarButtonItem(title: "Назад",
		                                 style: UIBarButtonItemStyle.plain,
		                                 target: self,
		                                 action: #selector(goBackPressed))
		navigationItem.leftBarButtonItem = backButton
		definesPresentationContext = true
		self.tableView.tableFooterView = UIView()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
		self.tableView.endEditing(true)
	}
	
	@objc fileprivate func goBackPressed() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func configureSearchController() {
		resultSearchController = UISearchController(searchResultsController: nil)
		resultSearchController.searchResultsUpdater = self
		resultSearchController.dimsBackgroundDuringPresentation = false
		resultSearchController.searchBar.sizeToFit()
		resultSearchController.searchBar.barTintColor = UIColor.white
		resultSearchController.searchBar.placeholder = "Начните вводить ФИО"
		resultSearchController.searchBar.delegate = self
		resultSearchController.searchBar.barStyle = .default
		resultSearchController.searchBar.backgroundColor = UIColor.clear
		self.tableView.tableHeaderView = resultSearchController.searchBar
	}
	
	func requestTeachers() {
		dataService.requestListOfTeachers { (teachers) in
			self.listOfTeachers = teachers
			self.makeTeacherDictionary()
		}
	}
	
	func makeTeacherDictionary() {
		teachersNames = listOfTeachers.map {$0.name}
		let characters = Array(Set(teachersNames.flatMap({$0.characters.first})))
		var result = [String: [String]]()
		for character in characters.map({ String($0)}) {
			teacherHeader.append(character)
			result[character] = teachersNames.filter({$0.hasPrefix(character)})
		}
		teacherDict = result
		teacherHeader.sort { $0 < $1 }
		tableView.reloadData()
	}

   
}

extension TeachersListTableViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return self.resultSearchController.isActive ? filteredDict.count : teacherDict.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.resultSearchController.isActive ?
			filteredDict[filteredHeader[section]]!.count : teacherDict[teacherHeader[section]]!.count
	}

	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return self.resultSearchController.isActive ? filteredHeader[section] : teacherHeader[section]
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "teacherCell", for: indexPath)
		if self.resultSearchController.isActive {
			cell.textLabel?.text = filteredDict[filteredHeader[indexPath.section]]![indexPath.row] }
		else {
			cell.textLabel?.text = teacherDict[teacherHeader[indexPath.section]]![indexPath.row]
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var selectedTeacherName: String!
		switch self.resultSearchController.isActive {
		case true:
			selectedTeacherName = filteredDict[filteredHeader[indexPath.section]]![indexPath.row]
		case false:
			selectedTeacherName = teacherDict[teacherHeader[indexPath.section]]![indexPath.row]
		}
		print("selected tracher name is \(selectedTeacherName)")
		let teachModel = listOfTeachers.filter({$0.name == selectedTeacherName}).first
		let VC = self.storyboard?.instantiateViewController(withIdentifier: timetableIdentifire) as! SubjectTabBarController
	  UserDefaults.standard.set(selectedTeacherName, forKey: "timetable.teacherName")
		VC.subjectState = ScheduleSate.teacher
		VC.teacherId = teachModel!.id
		let navVC = UINavigationController(rootViewController: VC)
		navVC.modalTransitionStyle = .crossDissolve
		self.present(navVC, animated: true, completion: nil)
	}
	
}

extension TeachersListTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
	func updateSearchResults(for searchController: UISearchController) {
		filteredHeader.removeAll()
		filteredDict.removeAll(keepingCapacity: false)
		let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchController.searchBar.text!)
		let filterredArray = (teachersNames as? NSArray)?.filtered(using: searchPredicate) as! [String]
		let characters = Array(Set(filterredArray.flatMap({$0.characters.first})))
		var result = [String: [String]]()
		for character in characters.map({ String($0)}) {
			filteredHeader.append(character)
			result[character] = filterredArray.filter({$0.hasPrefix(character)})
		}
		filteredDict = result
		filteredHeader.sort { $0 < $1 }
		self.tableView.reloadData()
	}
}
