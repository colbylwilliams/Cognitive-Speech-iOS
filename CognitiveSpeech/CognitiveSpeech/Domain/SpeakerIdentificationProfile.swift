//
//  SpeakerIdentificationProfile.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerIdentificationProfile: SpeakerProfile {
	
	static let profileIdKey = "identificationProfileId"
	
	private let enrollmentSpeechTimeKey = "enrollmentSpeechTime"
	private let remainingEnrollmentSpeechTimeKey = "remainingEnrollmentSpeechTime"
	
	var enrollmentSpeechTime: Double?
	var remainingEnrollmentSpeechTime: Double?
	
	override var timeCount: String? {
		return "\(enrollmentSpeechTime ?? 0)"
	}
	
	override var timeCountRemaining: String? {
		return "\(remainingEnrollmentSpeechTime ?? 0)"
	}
	
	init(fromJson dict: [String:Any], name: String?, isoFormatter: ISO8601DateFormatter?) {
		super.init()
		if let profileId = dict[SpeakerIdentificationProfile.profileIdKey] as? String {
			self.profileId = profileId
		}
		self.update(fromJson: dict, profileName: name ?? "unknown", isoFormatter: isoFormatter)
	}
	
	override func reset() {
		print("Reset")
		super.reset()
		self.enrollmentSpeechTime = 0.0
		self.remainingEnrollmentSpeechTime = 30.0 // default
	}
	
	override func update(fromJson dict: [String:Any], profileName name: String? = nil, isoFormatter: ISO8601DateFormatter?) {
		super.update(fromJson: dict, profileName: name, isoFormatter: isoFormatter)
		
		if let enrollmentSpeechTime = dict[enrollmentSpeechTimeKey] as? Double {
			self.enrollmentSpeechTime = enrollmentSpeechTime
		}
		if let remainingEnrollmentSpeechTime = dict[remainingEnrollmentSpeechTimeKey] as? Double {
			self.remainingEnrollmentSpeechTime = remainingEnrollmentSpeechTime
		}
	}
}
