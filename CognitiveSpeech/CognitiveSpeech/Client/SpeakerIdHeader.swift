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
	static let subscriptionValue = "" // https://portal.azure.com/#create/Microsoft.CognitiveServices/apitype/SpeakerRecognition/pricingtier/S0
}
