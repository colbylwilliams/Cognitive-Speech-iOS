//
//  SpeakerVerificationResult.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerVerificationResult {
	let resultKey = "result"
	let convenienceKey = "confidence"
	let phraseKey = "phrase"
	
	var result: String? // "Accept", // [Accept | Reject]
	var confidence: SpeakerResultConfidence? // "Normal", // [Low | Normal | High]
	var phrase: String?  //"recognized phrase"
	
	init(fromJson dict: [String:Any]) {
		if let result = dict[resultKey] as? String {
			self.result = result
		}
		if let confidenceString = dict[convenienceKey] as? String, let confidence = SpeakerResultConfidence(rawValue: confidenceString) {
			self.confidence = confidence
		}
		if let phrase = dict[phraseKey] as? String {
			self.phrase = phrase
		}
	}
}

enum SpeakerResultConfidence : String {
	case low = "Low"
	case normal = "Normal"
	case high = "High"
}
