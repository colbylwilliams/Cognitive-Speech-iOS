//
//  SpeakerProfile.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerProfile {
	
	private let localeKey = "locale"
	private let createdDateTimeKey = "createdDateTime"
	private let lastActionDateTimeKey = "lastActionDateTime"
	private let enrollmentStatusKey = "enrollmentStatus"
	
	var name: String!
	var profileId: String!
	var locale: String? = "en-US"
	var createdDateTime: Date?
	var lastActionDateTime: Date?
	var enrollmentStatus: SpeakerProfileEnrollmentStatus?
	
	// Override
	var timeCount: String? {
		return ""
	}
	// Override
	var timeCountRemaining: String? {
		return ""
	}
	
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
	
	func update(fromJson dict: [String:Any], profileName name: String? = nil, isoFormatter: ISO8601DateFormatter?) {
		if let name = name {
			self.name = name
		}
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
