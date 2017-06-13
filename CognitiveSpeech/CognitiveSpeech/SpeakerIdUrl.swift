//
//  SpeakerIdUrl.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

enum SpeakerIdUrl : String {
	
	case host = "westus.api.cognitive.microsoft.com"
	case base = "/spid/v1.0"
	case verify = "/verify"
	case identify = "/identify"
	case verificationProfiles = "/verificationProfiles"
	case identificationProfiles = "/identificationProfiles"
	case verificationPhrases = "/verificationPhrases"
	case operations = "/operations"
	
	var url: URL? {
		return URL(string: self.path)
	}
	
	func enrollUrl (_ profileId: String) -> URL? {
//		return URL(string: "\(self.enrollPath(profileId))?shortAudio=true")
		return URL(string: self.enrollPath(profileId))
	}
	
	func resetUrl (_ profileId: String) -> URL? {
		return URL(string: self.enrollPath(profileId))
	}
	
	func url(withId: String) -> URL? {
		return URL(string: "\(self.path)/\(withId)")
	}
	
	var path: String {
		let root = "https://\(SpeakerIdUrl.host.rawValue)\(SpeakerIdUrl.base.rawValue)"
		
		if self == .host || self == .base {
			return root
		} else {
			return "\(root)\(self.rawValue)"
		}
	}
	
	func enrollPath (_ profileId: String) -> String {
		if self == .verificationProfiles || self == .identificationProfiles {
			return "\(self.path)/\(profileId)/enroll"
		} else {
			return self.path
		}
	}
	
	func resetPath (_ profileId: String) -> String {
		if self == .verificationProfiles || self == .identificationProfiles {
			return "\(self.path)/\(profileId)/reset"
		} else {
			return self.path
		}
	}
}
