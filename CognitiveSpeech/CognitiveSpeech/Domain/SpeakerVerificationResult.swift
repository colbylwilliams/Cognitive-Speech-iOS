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
	
	var result: SpeakerVerificaitonResultResult?
	var confidence: SpeakerResultConfidence?
	var phrase: String?
	
	var verificationResultDetails: (title: String, detail: String?) {
		var detail: String? = nil
		if let confidence = confidence?.rawValue {
			detail = "Confidence: \(confidence)"
		}
		return ("Verification \(result?.rawValuePastTense ?? "failed")", detail)
	}
	
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
