//
//  SpeakerIdentificationEnrollmentResult.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerIdentificationEnrollmentResult : SpeakerEnrollmentResult {
	
	private let remainingEnrollmentSpeechTimeKey = "remainingEnrollmentSpeechTime"
	private let speechTimeKey = "speechTime"
	private let enrollmentSpeechTimeKey = "enrollmentSpeechTime"
	
	var remainingEnrollmentSpeechTime: Double?
	var speechTime: Double?
	var enrollmentSpeechTime: Double?
	
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
