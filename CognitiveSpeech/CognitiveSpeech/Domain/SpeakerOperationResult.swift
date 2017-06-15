//
//  OperationStatus.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerOperationResult {
	
	private let statusKey = "status"
	private let createdDateTimeKey = "createdDateTime"
	private let lastActionDateTimeKey = "lastActionDateTime"
	private let processingResultKey = "processingResult"
	private let messageKey = "message"
	
	var status: SpeakerOperationResultStatus? // "running"
	var createdDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var lastActionDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var enrollmentResult: SpeakerEnrollmentResult?
	var identificationResult: SpeakerIdentificationReslut?
	var message: String?
	var processingResult: [String:Any]?
	
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
	
	init(fromJson dict: [String:Any], isoFormatter: ISO8601DateFormatter?) {
		if let statusString = dict[statusKey] as? String, let status = SpeakerOperationResultStatus(rawValue: statusString) {
			self.status = status
		}
		if let createdDateTime = dict[createdDateTimeKey] as? String {
			self.createdDateTime = isoFormatter?.date(from: createdDateTime)
		}
		if let lastActionDateTime = dict[lastActionDateTimeKey] as? String {
			self.lastActionDateTime = isoFormatter?.date(from: lastActionDateTime)
		}
		if let message = dict[messageKey] as? String {
			self.message = message
		}
		if let processingResult = dict[processingResultKey] as? [String:Any] {
			self.processingResult = processingResult
			// Check if this is a SpeakerProfile or SpeakerIdentificationReslut
			if let _ = processingResult["processingResult"] {
				self.identificationResult = SpeakerIdentificationReslut(fromJson: processingResult)
			} else if let _ = processingResult["enrollmentStatus"] {
				self.enrollmentResult = SpeakerEnrollmentResult(fromJson: processingResult)
			}
		}
	}
}
