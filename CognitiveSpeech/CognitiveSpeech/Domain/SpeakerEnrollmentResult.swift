//
//  SpeakerEnrollmentResult.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/14/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerEnrollmentResult {
	
	private let enrollmentStatusKey = "enrollmentStatus"
	
	var enrollmentStatus: SpeakerProfileEnrollmentStatus? // "Enrolled"
	
	init?(fromJson dict: [String:Any]?) {
		if let dict = dict, let enrollmentStatusString = dict[enrollmentStatusKey] as? String, let enrollmentStatus = SpeakerProfileEnrollmentStatus(rawValue: enrollmentStatusString) {
			self.enrollmentStatus = enrollmentStatus
		} else {
			return nil
		}
	}
}
