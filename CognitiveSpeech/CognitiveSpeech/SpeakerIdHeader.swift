//
//  SpeakerIdHeader.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

struct SpeakerIdHeaders {
	static let contentTypeKey = "Content-Type"
	static let contentTypeValue = "application/json"
	
	static let subscriptionKey = "Ocp-Apim-Subscription-Key"
	static let subscriptionValue = "0e71b5bf7bc645a182196bf58789268c"
}
//
//enum SpeakerIdHeader : String {
//	
//	case contentType = "Content-Type"
//	case subscriptionKey = "Ocp-Apim-Subscription-Key"
//	
//	var key: String {
//		return self.rawValue
//	}
//	
//	var value: String {
//		switch self {
//		case .contentType:
//			return "application/json"
//		case .subscriptionKey:
//			return "0e71b5bf7bc645a182196bf58789268c"
//		}
//	}
//}
