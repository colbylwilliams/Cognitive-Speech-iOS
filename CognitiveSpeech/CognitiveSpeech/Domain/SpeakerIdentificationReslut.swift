//
//  IdentificationReslut.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerIdentificationReslut {
	
	private let identifiedProfileIdKey = "identifiedProfileId"
	private let convenienceKey = "confidence"
	
	var identifiedProfileId: String?
	var confidence: SpeakerResultConfidence?
	
	var confidenceString: String {
		return confidence?.rawValue ?? "Unknown"
	}
	
	init(fromJson dict: [String:Any]) {
		if let identifiedProfileId = dict[identifiedProfileIdKey] as? String {
			self.identifiedProfileId = identifiedProfileId
		}
		if let confidenceString = dict[convenienceKey] as? String, let confidence = SpeakerResultConfidence(rawValue: confidenceString) {
			self.confidence = confidence
		}
	}
}
