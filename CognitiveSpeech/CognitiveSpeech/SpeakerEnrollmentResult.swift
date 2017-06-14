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
	private let remainingEnrollmentSpeechTimeKey = "remainingEnrollmentSpeechTime"
	private let speechTimeKey = "speechTime"
	private let enrollmentSpeechTimeKey = "enrollmentSpeechTime"
	
	var enrollmentStatus: SpeakerProfileEnrollmentStatus? // "Enrolled"
	var remainingEnrollmentSpeechTime: Double? // 0.0,
	var speechTime: Double? // 0.0
	var enrollmentSpeechTime: Double? // 0.0
	
	init(fromJson dict: [String:Any]) {
		if let enrollmentStatusString = dict[enrollmentStatusKey] as? String, let enrollmentStatus = SpeakerProfileEnrollmentStatus(rawValue: enrollmentStatusString) {
			self.enrollmentStatus = enrollmentStatus
		}
		if let remainingEnrollmentSpeechTime = dict[remainingEnrollmentSpeechTimeKey] as? Double {
			self.remainingEnrollmentSpeechTime = remainingEnrollmentSpeechTime
		}
		if let speechTime = dict[speechTimeKey] as? Double {
			self.speechTime = speechTime
		}
		if let enrollmentSpeechTime = dict[enrollmentSpeechTimeKey] as? Double {
			self.enrollmentSpeechTime = enrollmentSpeechTime
		}
	}
}
