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
	
	override init?(fromJson dict: [String:Any]?) {
		super.init(fromJson: dict)
		if let dict = dict, let remainingEnrollmentSpeechTime = dict[remainingEnrollmentSpeechTimeKey] as? Double, let speechTime = dict[speechTimeKey] as? Double, let enrollmentSpeechTime = dict[enrollmentSpeechTimeKey] as? Double {
			self.remainingEnrollmentSpeechTime = remainingEnrollmentSpeechTime
			self.speechTime = speechTime
			self.enrollmentSpeechTime = enrollmentSpeechTime
		} else {
			return nil
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
	
	override init?(fromJson dict: [String:Any]?) {
		super.init(fromJson: dict)
		if let dict = dict, let enrollmentsCount = dict[enrollmentsCountKey] as? Double, let remainingEnrollments = dict[remainingEnrollmentsKey] as? Double, let phrase = dict[phraseKey] as? String {
			self.enrollmentsCount = enrollmentsCount
			self.remainingEnrollments = remainingEnrollments
			self.phrase = phrase
		} else {
			return nil
		}
	}
}


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
