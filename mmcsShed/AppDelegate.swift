//
//  AppDelegate.swift
//  mmcsShed
//
//  Created by Danya on 01.02.17.
//  Copyright © 2017 Danya. All rights reserved.
//

import UIKit
import CoreData

var isAuthorized: Bool {
	get {
		return UserDefaults.standard.bool(forKey: "isAuthorized")
	}
	set {
		UserDefaults.standard.set(newValue, forKey: "isAuthorized")
	}
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		self.window?.rootViewController = rootVC()
		return true
	}
	
	func rootVC() -> UIViewController {
		switch isAuthorized {
		case true:
			let VC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "timetable") as! SubjectTabBarController
			let navVC = UINavigationController(rootViewController: VC)
			return navVC
		default:
			let VC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
			return VC!
		}
	}


}

