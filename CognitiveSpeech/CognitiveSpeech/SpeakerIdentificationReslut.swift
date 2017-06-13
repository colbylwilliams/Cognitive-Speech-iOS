//
//  IdentificationReslut.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerIdentificationReslut {
	let identifiedProfileIdKey = "identifiedProfileId"
	let convenienceKey = "confidence"
	
	var identifiedProfileId: String?
	var confidence: SpeakerResultConfidence? // "Normal", // [Low | Normal | High]
	
	init(fromJson dict: [String:Any]) {
		if let identifiedProfileId = dict[identifiedProfileIdKey] as? String {
			self.identifiedProfileId = identifiedProfileId
		}
		if let confidenceString = dict[convenienceKey] as? String, let confidence = SpeakerResultConfidence(rawValue: confidenceString) {
			self.confidence = confidence
		}
	}
}
