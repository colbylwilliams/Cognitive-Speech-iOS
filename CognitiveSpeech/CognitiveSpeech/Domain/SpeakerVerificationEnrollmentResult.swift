//
//  SpeakerVerificationEnrollmentResult.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

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
