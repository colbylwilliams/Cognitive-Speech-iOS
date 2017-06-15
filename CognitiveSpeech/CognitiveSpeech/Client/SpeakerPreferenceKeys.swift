//
//  SpeakerPreferenceKeys.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/14/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

struct SpeakerPreferenceKeys {
	static let speakerType = "\(Bundle.main.bundleIdentifier ?? "cognitive.speech").speakerType"
	static let shortAudio = "\(Bundle.main.bundleIdentifier ?? "cognitive.speech").shortAudio"
	static let selectedIdentificationProfileId = "\(Bundle.main.bundleIdentifier ?? "cognitive.speech").selectedIdentificationProfileId"
	static let selectedVerificationProfileId = "\(Bundle.main.bundleIdentifier ?? "cognitive.speech").selectedVerificationProfileId"
	static func nameForProfileId (profileId: String) -> String {
		return "\(Bundle.main.bundleIdentifier ?? "cognitive.speech").nameForProfileId.\(profileId)"
	}
	static func phraseForProfileId (profileId: String) -> String {
		return "\(Bundle.main.bundleIdentifier ?? "cognitive.speech").phraseForProfileId.\(profileId)"
	}
}
