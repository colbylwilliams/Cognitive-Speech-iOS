//
//  OperationStatus.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerOperationResult {
	
	let statusKey = "status"
	let createdDateTimeKey = "createdDateTime"
	let lastActionDateTimeKey = "lastActionDateTime"
	let processingResultKey = "processingResult"
	let messageKey = "message"
	
	private	var _dateFormatter: DateFormatter?
	var dateFormatter: DateFormatter? {
		if _dateFormatter == nil {
			_dateFormatter = DateFormatter()
			_dateFormatter?.dateStyle = .short
			_dateFormatter?.timeStyle = .short
		}
		return _dateFormatter
	}
	
	private	var _isoFormatter: ISO8601DateFormatter?
	var isoFormatter: ISO8601DateFormatter? {
		if _isoFormatter == nil {
			_isoFormatter = ISO8601DateFormatter()
			_isoFormatter?.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		}
		return _isoFormatter
	}
	
	var status: SpeakerOperationResultStatus? // "running"
	var createdDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var lastActionDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var enrollmentResult: SpeakerProfile?
	var identificationResult: SpeakerIdentificationReslut?
	var message: String?
	
	var createdDateTimeString: String {
		if let createdDateTime = createdDateTime {
			return dateFormatter?.string(from: createdDateTime) ?? ""
		}
		return ""
	}
	
	var lastActionDateTimeString: String {
		if let lastActionDateTime = lastActionDateTime {
			return dateFormatter?.string(from: lastActionDateTime) ?? ""
		}
		return ""
	}

	
	init(fromJson dict: [String:Any]) {
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
			// Check if this is a SpeakerProfile or SpeakerIdentificationReslut
			if let _ = processingResult["processingResult"] {
				self.identificationResult = SpeakerIdentificationReslut(fromJson: processingResult)
			} else if let _ = processingResult["enrollmentStatus"] {
				self.enrollmentResult = SpeakerProfile(fromJson: processingResult)
			}
		}
	}
}

enum SpeakerOperationResultStatus : String {
	case notstarted // The operation is not started.
	case running // The operation is running.
	case failed // The operation is finished and failed.
	case succeeded // The operation is finished and succeeded.
}
