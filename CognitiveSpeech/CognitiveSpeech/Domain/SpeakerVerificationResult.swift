//
//  SpeakerVerificationResult.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/13/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerVerificationResult {
	
	private let resultKey = "result"
	private let convenienceKey = "confidence"
	private let phraseKey = "phrase"
	
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
