//
//  SpeakerProfileEnrollmentStatus.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation
import UIKit

enum SpeakerProfileEnrollmentStatus : String {
	
	static let green = UIColor(red: 0, green: 0.5, blue: 0, alpha: 1)
	
	case enrolling = "Enrolling"	// profile is currently enrolling and is not ready for identification
	case training = "Training"		// profile is currently training and is not ready for identification
	case enrolled = "Enrolled"		// profile is currently enrolled and is ready for identification
	
	var color: UIColor {
		switch self {
		case .enrolling:
			return UIColor.orange
		case .training:
			return UIColor.orange
		case .enrolled:
			return SpeakerProfileEnrollmentStatus.green
		}
	}
}
