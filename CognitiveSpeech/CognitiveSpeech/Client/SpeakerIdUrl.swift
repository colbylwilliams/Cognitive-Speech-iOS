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
	
	func url(withLocale locale: String) -> URL? {
		let string = "\(self.path)?locale=\(locale)"
		return URL(string: string)
	}
	
	func verifyUrl(profileId: String) -> URL? {
		let string = "\(self.path)?verificationProfileId=\(profileId)"
		return URL(string: string)
	}
	
	func identifyUrl(useShort: Bool = false, profileIds: [String]) -> URL? {
		guard profileIds.count > 0 else {
			print("Must provide one or more profileIds")
			return nil
		}
		
		if profileIds.count > 10 {
			print("Speech API only supports up to 10 profileIds")
		}
		
		let profileIdsParam = profileIds.prefix(10).joined(separator: ",")
		
		var string = "\(self.path)?identificationProfileIds=\(profileIdsParam)"
		
		if useShort { string += "&shortAudio=true" }
		
		return URL(string: string)
	}
	
	func enrollUrl (_ profileId: String, useShort: Bool = false) -> URL? {
		var string = self.enrollPath(profileId)
		
		if useShort && self == .identificationProfiles { string += "?shortAudio=true" }
		
		return URL(string: string)
	}
	
	func resetUrl (_ profileId: String) -> URL? {
		return URL(string: self.resetPath(profileId))
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
