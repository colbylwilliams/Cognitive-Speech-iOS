//
//  SpeakerProfileEnrollmentStatus.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

enum SpeakerProfileEnrollmentStatus : String {
	case enrolling = "Enrolling"	// profile is currently enrolling and is not ready for identification
	case training = "Training"		// profile is currently training and is not ready for identification
	case enrolled = "Enrolled"		// profile is currently enrolled and is ready for identification
}
