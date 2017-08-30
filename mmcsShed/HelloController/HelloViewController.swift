//
//  HelloViewController.swift
//  mmcsShed
//
//  Created by Danya on 22.04.17.
//  Copyright © 2017 Danya. All rights reserved.
//
import UIKit
import Foundation
import JJHUD

enum StepState: Int {
	case bachelor = 0
	case master
	case postgraduate
	
	var describeSelf: String {
		switch self {
		case .bachelor:
			return "bachelor"
		case .master:
			return "master"
		case .postgraduate:
			return "postgraduate"
		}
	}
}

final class HelloViewController: UIViewController {
	
	//Properties
	fileprivate var curWeek: Int?
	fileprivate var whiteViewFrame: CGRect?
	fileprivate var timetableIdentifire = "timetable"
	fileprivate var dataService = DataService()
	fileprivate var kourseList = ["1", "2", "3", "4"]
	fileprivate var groupList = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
	fileprivate let designView = UIView()
	fileprivate var buttonPath: UIBezierPath!
	
	fileprivate lazy var currentEducationInfo: SelectedEducation = {
		return SelectedEducation()
	}()
	fileprivate lazy var height: CGFloat = {
		return UIScreen.main.bounds.height
	}()
	fileprivate lazy var width: CGFloat = {
		return UIScreen.main.bounds.width
	}()
	private (set) lazy var orderedViewControllers:[UIViewController] = {
		let startVC = self.viewAtIndex(index: 0) as? PageViewContentController
		guard let start = startVC else {
			return [UIViewController()]
		}
		return [
			start
		]
	}()
	
	var pageController: UIPageViewController!
	
	//IBOutlets
	@IBOutlet weak var teachersButton: UIButton! {
		didSet {
			let currentColor = UIColor.init(hex: "#9999ff")
			teachersButton.layer.borderWidth = 2.0
			teachersButton.layer.borderColor = currentColor.cgColor
			teachersButton.addTarget(self, action: #selector(self.teachersButtonPressed(_:event:)), for: .touchUpInside)
			teachersButton.setTitleColor(currentColor, for: .normal)
			teachersButton.titleLabel?.adjustsFontSizeToFitWidth = true
			teachersButton.titleLabel?.numberOfLines = 1
			teachersButton.setTitle("Расписание преподавателей", for: .normal)
		}
	}
	@IBOutlet weak var containerView: UIView!
	@IBOutlet weak var mmcsImage: UIImageView! {
		didSet {
			let image = #imageLiteral(resourceName: "mmcs")
			let originalImage = CIImage.init(image: image)
			let filter = CIFilter.init(name: "CIPhotoEffectTransfer")
			filter?.setDefaults()
			filter?.setValue(originalImage, forKey: kCIInputImageKey)
			let outputImage = filter?.outputImage
			let uiOutputImage = UIImage.init(ciImage: outputImage!)
			mmcsImage.image = uiOutputImage
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.pageController = self.storyboard?.instantiateViewController(withIdentifier: "pageVC") as? UIPageViewController
		self.pageController.dataSource = self
		self.pageController.delegate = self
		self.pageController.setViewControllers(orderedViewControllers, direction: .forward, animated: true, completion: nil)
		let containerWidth = self.containerView.frame.width
		let containerHeight = self.containerView.frame.height
		self.pageController.view.frame = CGRect(x: 0,
		                                        y: 0,
		                                        width: containerWidth,
		                                        height: containerHeight)
		//self.view.bringSubview(toFront: pageIndicator)
		self.containerView.addSubview(pageController.view)
		self.pageController.didMove(toParentViewController: self)
		removeSwipeGesture()
	}
	
	
	func setCourseWithGroup() {
		JJHUD.showLoading()
		var usingKourse = currentEducationInfo.kourse!
		let usingGroup = currentEducationInfo.group!
		UserDefaults.standard.set(usingKourse, forKey: "timetable.kourse")
		if currentEducationInfo.step == StepState.master {
			switch currentEducationInfo.kourse! {
			case 1:
				UserDefaults.standard.set(6, forKey: "timetable.kourse")
				usingKourse = 1
			case 2:
				UserDefaults.standard.set(7, forKey: "timetable.kourse")
				usingKourse = 2
			default:
				break
			}
		} else if currentEducationInfo.step == StepState.postgraduate {
			switch currentEducationInfo.kourse! {
			case 1:
				usingKourse = 1
				UserDefaults.standard.set(8, forKey: "timetable.kourse")
			case 2:
				UserDefaults.standard.set(9, forKey: "timetable.kourse")
				usingKourse = 2
			default:
				break
			}
		}
		print("data = \n",usingKourse, usingGroup)
		dataService.checkUserInfo(step: currentEducationInfo.step!.describeSelf,
		                          kourse: usingKourse,
		                          group: usingGroup) { (isHave) in
																JJHUD.hide()
																if isHave {
																	print("we have such group")
																	UserDefaults.standard.set(usingGroup, forKey: "timetable.group")
																	isAuthorized = true
																	self.presentTimetableVC()
																} else {
																	self.showErrorAlert()
																}
		}
	}
	
	func showErrorAlert() {
		let alert = UIAlertController.init(title: "Что-то пошло не так.", message: "", preferredStyle: .alert)
		alert.addAction(UIAlertAction.init(title: "Попробовать еще раз", style: .cancel, handler: { (action) in
			self.currentEducationInfo = SelectedEducation()
			self.pageController.setViewControllers([(self.viewAtIndex(index: 0) as? PageViewContentController)!],
			                                       direction: .forward,
			                                       animated: true,
			                                       completion: nil)
		}))
		self.present(alert, animated: true, completion: nil)
	}
	
	func initializeImageView() {
		whiteViewFrame = CGRect.init(x: 0,
		                             y: mmcsImage.bounds.height - mmcsImage.bounds.height / 3,
		                             width: mmcsImage.bounds.width,
		                             height: mmcsImage.bounds.height / 3)
		let whiteView = UIView(frame: whiteViewFrame!)
		let bezierPath = UIBezierPath(rect: whiteView.bounds)
		bezierPath.move(to: CGPoint(x: 0, y: 0))
		bezierPath.addLine(to: CGPoint(x: width / 3, y: whiteView.bounds.height / 2))
		bezierPath.addLine(to: CGPoint(x: width, y: 0))
		bezierPath.close()
		bezierPath.stroke()
		bezierPath.reversing()
		whiteView.backgroundColor = .white
		whiteView.clipsToBounds = true
		whiteView.addMask(bezierPath)
		view.addSubview(whiteView)
		print("mmcs bounds = ", mmcsImage.bounds, whiteView.bounds)
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		initializeImageView()
		initializeDesignView()
	}
	
	func initializeDesignView() {
		designView.frame = whiteViewFrame!
		buttonPath = UIBezierPath(rect: whiteViewFrame!)
		buttonPath.move(to: CGPoint(x: 0, y: 0))
		buttonPath.addLine(to: CGPoint(x: width / 3, y: whiteViewFrame!.height / 2))
		buttonPath.addLine(to: CGPoint(x: width, y: 0))
		buttonPath.addLine(to: CGPoint(x: width, y: whiteViewFrame!.height / 2 -  whiteViewFrame!.height / 3 - 7))
		buttonPath.addLine(to: CGPoint(x: width / 3, y: whiteViewFrame!.height -  whiteViewFrame!.height / 3 - 7))
		buttonPath.addLine(to: CGPoint(x: 0, y: whiteViewFrame!.height / 2 -  whiteViewFrame!.height / 3 - 7))
		buttonPath.addLine(to: CGPoint(x: 0, y: 0))
		buttonPath.close()
		buttonPath.stroke()
		buttonPath.reversing()
		
		designView.backgroundColor = UIColor.init(hex: "#9999ff")
		designView.alpha = 0.692
		designView.clipsToBounds = true
		designView.addMask(buttonPath)
		self.view.addSubview(designView)
	}
	
	func removeSwipeGesture(){
		for view in self.pageController.view.subviews {
			if let subView = view as? UIScrollView {
				subView.isScrollEnabled = false
			}
		}
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.view.endEditing(true)
	}
	
	func teachersButtonPressed(_ sender : UIButton, event: UIEvent) {
		let VC = self.storyboard?.instantiateViewController(withIdentifier: "TeachersList") as! TeachersListTableViewController
		let navVC = UINavigationController(rootViewController: VC)
		navVC.modalTransitionStyle = .crossDissolve
		self.present(navVC, animated: true, completion: nil)
	}
	
	func presentTimetableVC() {
		let VC = self.storyboard?.instantiateViewController(withIdentifier: timetableIdentifire) as! SubjectTabBarController
		let navVC = UINavigationController(rootViewController: VC)
		navVC.modalTransitionStyle = .crossDissolve
		self.present(navVC, animated: true, completion: nil)
	}
	
}

extension HelloViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
	func viewAtIndex(index: Int) -> UIViewController? {
		if index > 2 {
			return PageViewContentController()
		}
		guard let VC: PageViewContentController = self.storyboard?.instantiateViewController(withIdentifier: String(describing: PageViewContentController.self))
			as? PageViewContentController else {
				return nil
		}
		VC.delegate = self
		VC.kourseList = self.kourseList
		VC.groupList = self.groupList
		VC.ind = index
		return VC
	}
	
	func pageViewController(_ pageViewController: UIPageViewController,
	                        viewControllerAfter viewController: UIViewController) -> UIViewController? {
		let VC = viewController as! PageViewContentController // swiftlint:disable:this force_cast
		var ind = VC.ind as Int
		guard ind < 2 && ind != NSNotFound else {
			return nil
		}
		ind += 1
		return self.viewAtIndex(index: ind)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
		let VC = viewController as! PageViewContentController // swiftlint:disable:this force_cast
		var ind = VC.ind as Int
		guard ind > 0 && ind != NSNotFound else {
			return nil
		}
		ind -= 1
		return self.viewAtIndex(index: ind)
	}
	
	func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
		guard completed else {
			return
		}
		let index = (pageViewController.viewControllers?.first as? PageViewContentController)?.ind
		guard index != nil else {
			return
		}
	}
	
}

extension HelloViewController: textfieldMainDelegate {
	func endEditing(with index: Int?, state: TextfieldValueState) {
		UIView.animate(withDuration: 0.3, animations: {
			self.mmcsImage.alpha = 1
			self.view.window?.frame.origin.y += 205
		}, completion: nil)
		
		switch state {
		case .stage:
			if let strongIndex = index {
				self.currentEducationInfo.step = StepState.init(rawValue: strongIndex)
			}
			guard self.currentEducationInfo.step != nil else {
				return
			}
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
				self.dataService.courseNumbers(with: self.currentEducationInfo.step!.describeSelf, complition: { kourses in
					self.kourseList = kourses.map {String($0)}
					self.pageController.setViewControllers([(self.viewAtIndex(index: 1) as? PageViewContentController)!],
					                                       direction: .forward,
					                                       animated: true,
					                                       completion: nil)
				})
			}
		case .kourse:
			self.currentEducationInfo.kourse = index
			guard self.currentEducationInfo.kourse != nil else {
				return
			}
			var usableKourse = index
			if currentEducationInfo.step == StepState.master {
				switch currentEducationInfo.kourse! {
				case 1:
					usableKourse = 6
				case 2:
					usableKourse = 7
				default:
					break
				}
			} else if currentEducationInfo.step == StepState.postgraduate {
				switch currentEducationInfo.kourse! {
				case 1:
					usableKourse = 8
				case 2:
					usableKourse = 9
				default:
					break
				}
			}
			
			DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
				self.dataService.groupNumber(kourse: usableKourse!, complition: { groups in
					self.groupList = groups.map {String($0)}
					self.pageController.setViewControllers([(self.viewAtIndex(index: 2) as? PageViewContentController)!],
					                                       direction: .forward,
					                                       animated: true,
					                                       completion: nil)
				})
			}
		case .group:
			self.currentEducationInfo.group = index
			guard self.currentEducationInfo.group != nil else {
				return
			}
			self.setCourseWithGroup()
		}
	}
	
	func beginEditing() {
		UIView.animate(withDuration: 0.3, animations: {
			self.mmcsImage.alpha = 0.284
			self.view.window?.frame.origin.y -= 205
		}, completion: nil)
	}
}
