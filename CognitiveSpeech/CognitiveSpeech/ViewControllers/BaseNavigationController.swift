//
//  BaseNavigationController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/16/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {
	
	override func viewDidLoad() {
		super .viewDidLoad()
		
//		let statusBarView = UIView()
//		statusBarView.backgroundColor = #colorLiteral(red: 0.1268855035, green: 0.5881022811, blue: 0.9535151124, alpha: 1)
//		navigationBar.barTintColor = #colorLiteral(red: 0.1003073379, green: 0.4618694186, blue: 0.823127687, alpha: 1)
//		
//		statusBarView.translatesAutoresizingMaskIntoConstraints = false
//		
//		view.addSubview(statusBarView)
//		
//		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[statusBarView]|", options: .directionLeadingToTrailing, metrics: [:], views: ["statusBarView":statusBarView]))
//		view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[statusBarView(20.0)]", options: .directionLeadingToTrailing, metrics: [:], views: ["statusBarView":statusBarView]))
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}
}
