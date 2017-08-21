//
//  SubjectTabBarController.swift
//  mmcsShed
//
//  Created by Danya on 09.05.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import UIKit
import JJHUD

enum ScheduleSate {
	case lessons
	case teacher
}

class SubjectTabBarController: UIViewController {
	
	var changesIndex: Int = 0
	var currentWeek: Int = 0
	var teacherId = 0
	var subjectState: ScheduleSate = .lessons
	
	fileprivate var lessons = [LessonModel]()
	fileprivate var teacherLessons = [LessonTeacherModel]()
	fileprivate lazy var coreDataManager: CoreDataManager = {
		return CoreDataManager()
	}()
	fileprivate var dataService = DataService()
	fileprivate var course: Int?
	fileprivate var group: Int?
	
	fileprivate lazy var weekendDayImage: UIImageView = {
		let imageFrame = CGRect.init(x: 0,
		                             y: 40,
		                             width: UIScreen.main.bounds.width,
		                             height: self.collectionView.frame.height - 80)
		let imageView = UIImageView(frame: imageFrame)
		imageView.contentMode = .scaleAspectFit
		return imageView
	}()
	
	@IBOutlet weak var collectionView: UICollectionView! {
		didSet {
			collectionView.delegate = self
			collectionView.dataSource = self
			let nib = UINib(nibName: "SubjectCollectionCell", bundle: Bundle.main)
			collectionView.register(nib, forCellWithReuseIdentifier: "subjectCell")
			collectionView.contentInset = UIEdgeInsets(top: 20, left: 10, bottom: 5, right: 10)
		}
	}
	
	@IBOutlet weak var tabBar: UITabBar! {
		didSet {
			tabBar.delegate = self
			tabBar.selectedItem = tabBar.items![changesIndex] as UITabBarItem
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setExitBtn()
		let dayNumber = Date().dayNumberOfWeek() == 1 ? 2 : Date().dayNumberOfWeek()
		self.changesIndex = dayNumber! - 2
		tabBar.selectedItem = tabBar.items![changesIndex] as UITabBarItem
		JJHUD.showLoading(text: "Обновляем расписание")
		initializeSecondNavBar()
		switch subjectState {
		case .lessons:
			self.course = UserDefaults.standard.integer(forKey: "timetable.kourse")
			self.group = UserDefaults.standard.integer(forKey: "timetable.group")
			self.title = "\(course!).\(group!)"
			configureShedule()
			downloadBefore()
		case .teacher:
			let teacherName = UserDefaults.standard.string(forKey: "timetable.teacherName")
			self.title = teacherName
			setTeachers()
		}
	}
	
	func initializeSecondNavBar() {
		let leftButton = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_filter"), style: .plain, target: self, action: #selector(changeOddOfWeek))
		self.navigationItem.rightBarButtonItem = leftButton
	}
	
	func changeOddOfWeek() {
		if currentWeek == 0 {
			currentWeek = 1
		} else {
			currentWeek = 0
		}
		weekendDayImage.removeFromSuperview()
		let oddWeek = currentWeek == 1 ? "нижняя" : "верхняя"
		JJHUD.showInfo(text: "Выбрана \(oddWeek) неделя", delay: 1.0)
		if subjectState == .lessons {
			self.configureShedule()
		} else {
			checkEmptyFilter()
			self.collectionView.reloadData()
		}
	}
	
	func downloadBefore() {
		dataService.requestCurrentWeek { curWeek in
			guard curWeek != -1 else {
				print("Error. Current week = -1")
				JJHUD.hide()
				JJHUD.showError(text: "Вероятно, нет подключения к интернету", delay: 1.0)
				return
			}
			self.currentWeek = curWeek
			self.dataService.requestOfGradeList(with: self.course!, group: self.group!) {
				if Date().dayNumberOfWeek() == 1 {
					self.currentWeek = self.currentWeek == 0 ? 1 : 0
				}
				print("current week = ", self.currentWeek)
				self.configureShedule()
				JJHUD.hide()
				JJHUD.showSuccess(text: "Обновлено!", delay: 1.0)
			}
		}
	}
	
	func setTeachers() {
		dataService.requestCurrentWeek { curWeek in
			guard curWeek != -1 else {
				print("Error. Current week = -1")
				JJHUD.hide()
				JJHUD.showError(text: "Вероятно, нет подключения к интернету", delay: 1.0)
				return
			}
			self.currentWeek = curWeek
			self.dataService.requestScheduleOfTeacher(with: self.teacherId, complition: { (teachers) in
				if Date().dayNumberOfWeek() == 1 {
					self.currentWeek = self.currentWeek == 0 ? 1 : 0
				}
				let sortedTeachers = teachers.sorted(by: { $0.timeSince < $1.timeSince})
				self.teacherLessons = sortedTeachers
				self.checkEmptyFilter()
				self.collectionView.reloadData()
				JJHUD.hide()
				JJHUD.showSuccess(text: "Обновлено!", delay: 1.0)
			})
		}
	}
	
	func setExitBtn() {
		let rightItem = UIBarButtonItem(image: #imageLiteral(resourceName: "row-reorder"),
		                                style: .plain,
		                                target: self,
		                                action: #selector(exitBtnPressed))
		self.navigationItem.leftBarButtonItem = rightItem
	}
	
	func exitBtnPressed() {
		coreDataManager.deleteEntities()
		isAuthorized = false
		let VC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
		VC?.modalTransitionStyle = .crossDissolve
		self.present(VC!, animated: true, completion: nil)
	}

	func configureShedule() {
		lessons.removeAll()
		weekendDayImage.removeFromSuperview()
		let lessonsCount = coreDataManager.countEntity(with: changesIndex)
		guard lessonsCount != 0  else {
			print("Bad way. No counted elements here")
			self.setWeekendImage()
			self.collectionView.reloadData()
			return
		}
		for index in 0...lessonsCount - 1 {
			let lessonData = coreDataManager.fetchForModel(with: changesIndex, indexPath: index)
			let teacherName = lessonData?.value(forKey: "teacherName") as! String
			let room = lessonData?.value(forKey: "room") as! String
			let timeSince = lessonData?.value(forKey: "timeSince") as! String
			let timeBefore = lessonData?.value(forKey: "timeBefore") as! String
			let subject = lessonData?.value(forKey: "subjectName") as! String
			let isUpper = lessonData?.value(forKey: "isUpper") as! Int
			let localModel = LessonModel(timeSince: timeSince, timeBefore: timeBefore, room: room, teacherName: teacherName, subjectName: subject, isUp: isUpper)
			if localModel.isUpper == 2 || localModel.isUpper == currentWeek {
				lessons.append(localModel)
			}
		}
		lessons = lessons.sorted(by: {$0.timeSince < $1.timeSince})
		self.collectionView.reloadData()
	}
	
	fileprivate func setWeekendImage() {
		weekendDayImage.image = #imageLiteral(resourceName: "WeekendImage")
		self.view.addSubview(weekendDayImage)
	}

	func checkEmptyFilter() {
		let filteredLessons = teacherLessons.filter {$0.dayOfWeek == self.changesIndex
			&& ($0.isUpper == 2 || $0.isUpper == self.currentWeek)}
		if filteredLessons.isEmpty {
			self.setWeekendImage()
		}
	}
	
}

extension SubjectTabBarController: UITabBarDelegate {
	
	func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
		changesIndex = item.tag
		weekendDayImage.removeFromSuperview()
		if subjectState == .lessons {
			configureShedule()
		} else {
			checkEmptyFilter()
			self.collectionView.reloadData()
		}
	}
	
}

extension SubjectTabBarController: UICollectionViewDelegate, UICollectionViewDataSource {
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch subjectState {
		case .lessons:
			return lessons.count
		case .teacher:
			let currentLessons = teacherLessons.filter { $0.dayOfWeek == self.changesIndex && ($0.isUpper == 2 || $0.isUpper == self.currentWeek) }
			return currentLessons.count
		}
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "subjectCell", for: indexPath) as! SubjectCollectionCell
		switch subjectState {
		case .lessons:
			cell.configure(timeS: lessons[indexPath.row].timeSince,
			               timeU: lessons[indexPath.row].timeBefore,
			               sbjName: lessons[indexPath.row].subjectName,
			               tchName: lessons[indexPath.row].teacherName,
			               roomS: lessons[indexPath.row].room + " к.")
		case .teacher:
			let currentLessons = teacherLessons.filter { $0.dayOfWeek == self.changesIndex }
			let currentLessonWithCurrentWeek = currentLessons.filter { $0.isUpper == 2 || $0.isUpper == self.currentWeek }
			
			cell.configure(timeS: currentLessonWithCurrentWeek[indexPath.row].timeSince,
			               timeU: currentLessonWithCurrentWeek[indexPath.row].timeBefore,
			               sbjName: currentLessonWithCurrentWeek[indexPath.row].subjectName,
			               tchName: currentLessonWithCurrentWeek[indexPath.row].teacherName,
			               roomS: currentLessonWithCurrentWeek[indexPath.row].room + " к.")
		}
		return cell

	}
	
	
}

extension SubjectTabBarController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
			return CGSize(width: UIScreen.main.bounds.width - 20, height: 100)
	}
	
}
