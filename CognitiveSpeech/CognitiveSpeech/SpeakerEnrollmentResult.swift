//
//  SpeakerEnrollmentResult.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/14/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerIdentificationEnrollmentResult : SpeakerEnrollmentResult {
	
	private let remainingEnrollmentSpeechTimeKey = "remainingEnrollmentSpeechTime"
	private let speechTimeKey = "speechTime"
	private let enrollmentSpeechTimeKey = "enrollmentSpeechTime"
	
	var remainingEnrollmentSpeechTime: Double? // 0.0,
	var speechTime: Double? // 0.0
	var enrollmentSpeechTime: Double? // 0.0
	
	override init(fromJson dict: [String:Any]) {
		super.init(fromJson: dict)
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


class SpeakerVerificationEnrollmentResult : SpeakerEnrollmentResult {
	
	private let phraseKey = "phrase"
	private let remainingEnrollmentsKey = "remainingEnrollments"
	private let enrollmentsCountKey = "enrollmentsCount"
	
	var enrollmentsCount: Double?
	var remainingEnrollments: Double?
	var phrase: String?
	
	override init(fromJson dict: [String:Any]) {
		super.init(fromJson: dict)
		if let enrollmentsCount = dict[enrollmentsCountKey] as? Double {
			self.enrollmentsCount = enrollmentsCount
		}
		if let remainingEnrollments = dict[remainingEnrollmentsKey] as? Double {
			self.remainingEnrollments = remainingEnrollments
		}
		if let phrase = dict[phraseKey] as? String {
			self.phrase = phrase
		}
	}
}


class SpeakerEnrollmentResult {
	
	private let enrollmentStatusKey = "enrollmentStatus"
	
	var enrollmentStatus: SpeakerProfileEnrollmentStatus? // "Enrolled"
	
	init(fromJson dict: [String:Any]) {
		if let enrollmentStatusString = dict[enrollmentStatusKey] as? String, let enrollmentStatus = SpeakerProfileEnrollmentStatus(rawValue: enrollmentStatusString) {
			self.enrollmentStatus = enrollmentStatus
		}
	}
}
