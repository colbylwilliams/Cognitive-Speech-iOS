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
	
	var result: SpeakerVerificaitonResultResult? // "Accept", // [Accept | Reject]
	var confidence: SpeakerResultConfidence? // "Normal", // [Low | Normal | High]
	var phrase: String?  //"recognized phrase"
	
	init(fromJson dict: [String:Any]) {
		if let resultString = dict[resultKey] as? String, let result = SpeakerVerificaitonResultResult(rawValue: resultString) {
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


enum SpeakerVerificaitonResultResult : String {
	case accept = "Accept"
	case reject = "Reject"
}


enum SpeakerResultConfidence : String {
	case low = "Low"
	case normal = "Normal"
	case high = "High"
}
