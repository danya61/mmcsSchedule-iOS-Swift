//
//  UIImage+MaskLayer.swift
//  mmcsShed
//
//  Created by Danya on 08.07.17.
//  Copyright © 2017 Danya. All rights reserved.
//
import UIKit
import Foundation

extension UIView {
	func addMask(_ bezierPath: UIBezierPath) {
		let pathMask = CAShapeLayer()
		pathMask.fillColor = UIColor.red.cgColor
		pathMask.path = bezierPath.cgPath
		pathMask.fillRule = kCAFillRuleEvenOdd
		layer.mask = pathMask
		clipsToBounds = true
	}
}
