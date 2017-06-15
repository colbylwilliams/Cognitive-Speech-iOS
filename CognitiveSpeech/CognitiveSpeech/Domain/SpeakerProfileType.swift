//
//  SpeakerProfileType.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

enum SpeakerProfileType: Int {
	case identification
	case verification
	
	var string: String {
		switch self {
		case .identification:
			return "Identification"
		case .verification:
			return "Verification"
		}
	}
	
	var url: SpeakerIdUrl {
		switch self {
		case .identification:
			return .identificationProfiles
		case .verification:
			return .verificationProfiles
		}
	}
}
