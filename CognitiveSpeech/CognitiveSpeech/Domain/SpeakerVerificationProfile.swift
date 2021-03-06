//
//  SpeakerVerificationProfile.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerVerificationProfile: SpeakerProfile {
	
	static let profileIdKey = "verificationProfileId"
	
	private let phraseKey = "phrase"
	private let enrollmentsCountKey = "enrollmentsCount"
	private let remainingEnrollmentsKey = "remainingEnrollments"
	private let remainingEnrollmentsCountKey = "remainingEnrollmentsCount"
	
	var enrollmentsCount: Double?
	var remainingEnrollmentsCount: Double?
	var phrase: String?
	
	override var timeCount: String? {
		return "\(enrollmentsCount ?? 0)"
	}
	
	override var timeCountRemaining: String? {
		return "\(remainingEnrollmentsCount ?? 0)"
	}
	
	init(fromJson dict: [String:Any], name: String?, isoFormatter: ISO8601DateFormatter?) {
		super.init()
		if let profileId = dict[SpeakerVerificationProfile.profileIdKey] as? String {
			self.profileId = profileId
		}
		self.update(fromJson: dict, profileName: name ?? "unknown", isoFormatter: isoFormatter)
	}
	
	override func reset() {
		print("Reset")
		super.reset()
		self.phrase = nil
		self.enrollmentsCount = 0
		self.remainingEnrollmentsCount = 3 // default
	}
	
	override func update(fromJson dict: [String:Any], profileName name: String? = nil, isoFormatter: ISO8601DateFormatter?) {
		super.update(fromJson: dict, profileName: name, isoFormatter: isoFormatter)
		
		if let enrollmentsCount = dict[enrollmentsCountKey] as? Double {
			self.enrollmentsCount = enrollmentsCount
		}
		if let remainingEnrollmentsCount = dict[remainingEnrollmentsCountKey] as? Double ?? dict[remainingEnrollmentsKey] as? Double {
			self.remainingEnrollmentsCount = remainingEnrollmentsCount
		}
		if let phrase = dict[phraseKey] as? String {
			self.phrase = phrase
		}
	}
}
