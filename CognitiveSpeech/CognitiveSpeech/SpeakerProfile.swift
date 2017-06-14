//
//  SpeakerProfile.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation


enum SpeakerProfileType: Int {
	case identification
	case verification
	
	var string: String {
		switch self {
		case .identification:
			return "Identification"
		case .verification:
			return "Verification"
		}
	}
	
	var url: SpeakerIdUrl {
		switch self {
		case .identification:
			return .identificationProfiles
		case .verification:
			return .verificationProfiles
		}
	}
}

class SpeakerIdentificationProfile: SpeakerProfile {
	
	static let profileIdKey = "identificationProfileId"
	
	private let enrollmentSpeechTimeKey = "enrollmentSpeechTime"
	private let remainingEnrollmentSpeechTimeKey = "remainingEnrollmentSpeechTime"
	
	var enrollmentSpeechTime: Double? // 0.0
	var remainingEnrollmentSpeechTime: Double? // 0.0,
	
	init(fromJson dict: [String:Any], isoFormatter: ISO8601DateFormatter?) {
		super.init()
		if let profileId = dict[SpeakerIdentificationProfile.profileIdKey] as? String {
			self.profileId = profileId
		}
		self.update(fromJson: dict, isoFormatter: isoFormatter)
	}
	
	override func reset() {
		print("Reset")
		super.reset()
		self.enrollmentSpeechTime = 0.0
		self.remainingEnrollmentSpeechTime = 20
	}
	
	override func update(fromJson dict: [String:Any], isoFormatter: ISO8601DateFormatter?) {
		super.update(fromJson: dict, isoFormatter: isoFormatter)
		
		if let enrollmentSpeechTime = dict[enrollmentSpeechTimeKey] as? Double {
			self.enrollmentSpeechTime = enrollmentSpeechTime
		}
		if let remainingEnrollmentSpeechTime = dict[remainingEnrollmentSpeechTimeKey] as? Double {
			self.remainingEnrollmentSpeechTime = remainingEnrollmentSpeechTime
		}
	}
}

class SpeakerVerificationProfile: SpeakerProfile {
	
	static let profileIdKey = "verificationProfileId"
	
	private let enrollmentsCountKey = "enrollmentsCount"
	private let remainingEnrollmentsCountKey = "remainingEnrollmentsCount"
	
	var enrollmentsCount: Double? // 0.0
	var remainingEnrollmentsCount: Double? // 0.0,
	
	init(fromJson dict: [String:Any], isoFormatter: ISO8601DateFormatter?) {
		super.init()
		if let profileId = dict[SpeakerVerificationProfile.profileIdKey] as? String {
			self.profileId = profileId
		}
		self.update(fromJson: dict, isoFormatter: isoFormatter)
	}
	
	override func reset() {
		print("Reset")
		super.reset()
		self.enrollmentsCount = 0.0
		self.remainingEnrollmentsCount = 20
	}
	
	override func update(fromJson dict: [String:Any], isoFormatter: ISO8601DateFormatter?) {
		super.update(fromJson: dict, isoFormatter: isoFormatter)
		
		if let enrollmentsCount = dict[enrollmentsCountKey] as? Double {
			self.enrollmentsCount = enrollmentsCount
		}
		if let remainingEnrollmentsCount = dict[remainingEnrollmentsCountKey] as? Double {
			self.remainingEnrollmentsCount = remainingEnrollmentsCount
		}
	}
}

class SpeakerProfile {
	
	private let localeKey = "locale"
	private let createdDateTimeKey = "createdDateTime"
	private let lastActionDateTimeKey = "lastActionDateTime"
	private let enrollmentStatusKey = "enrollmentStatus"
	
	var profileId: String! // "111f427c-3791-468f-b709-fcef7660fff9",
	var locale: String? = "en-US"
	var createdDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var lastActionDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var enrollmentStatus: SpeakerProfileEnrollmentStatus? // "Enrolled"
	
	func createdDateTimeString(dateFormatter: DateFormatter?) -> String {
		if let createdDateTime = createdDateTime {
			return dateFormatter?.string(from: createdDateTime) ?? ""
		}
		return ""
	}
	
	func lastActionDateTimeString(dateFormatter: DateFormatter?) -> String {
		if let lastActionDateTime = lastActionDateTime {
			return dateFormatter?.string(from: lastActionDateTime) ?? ""
		}
		return ""
	}
	
	func reset() {
		self.enrollmentStatus = .enrolling
	}
	
	func update(fromJson dict: [String:Any], isoFormatter: ISO8601DateFormatter?) {
		
		if let locale = dict[localeKey] as? String{
			self.locale = locale
		}
		if let createdDateTime = dict[createdDateTimeKey] as? String {
			self.createdDateTime = isoFormatter?.date(from: createdDateTime)
		}
		if let lastActionDateTime = dict[lastActionDateTimeKey] as? String {
			self.lastActionDateTime = isoFormatter?.date(from: lastActionDateTime)
		}
		if let enrollmentStatusString = dict[enrollmentStatusKey] as? String, let enrollmentStatus = SpeakerProfileEnrollmentStatus(rawValue: enrollmentStatusString) {
			self.enrollmentStatus = enrollmentStatus
		}
	}
}

