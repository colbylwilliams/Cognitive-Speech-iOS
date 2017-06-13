//
//  SpeakerProfile.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import Foundation

class SpeakerProfiles {
	
	private let preferenceId = "\(Bundle.main.bundleIdentifier ?? "cognitive.speech").identificationProfileId"
	
	private var selectedIndex: Int?
	
	var selected: SpeakerProfile? {
		if let selectedIndex = selectedIndex {
			if selectedIndex < profiles.count {
				return profiles[selectedIndex]
			}
		}
		return nil
	}
	
	var profiles: [SpeakerProfile] = [] {
		willSet(newValue) {
			print("Profiles WillSet")
		}
		didSet {
			print("Profiles DidSet")
			if profiles.count > 0 && selectedIndex == nil{
				selectedIndex = 0
			} else if profiles.count <= 0 {
				selectedIndex = nil
			}
		}
	}
	
	func setSelected(index: Int) {
		if index < profiles.count {
			selectedIndex = index
		}
	}
	
//	init() {
//		do {
//			if let data = UserDefaults.standard.data(forKey: preferenceId), let json = try JSONSerialization.jsonObject(with: data, options: []) as? [SpeakerProfile] {
//				profiles = json
//			}
//		}
//		catch {
//			print("Unable to get SpeakerProfiles from UserDefaults")
//		}
//	}
//
//	func save() {
//		do {
//			if profiles.count > 0 {
//
//				let data = try JSONSerialization.data(withJSONObject: profiles, options: [])
//
//				if let dataString = String(data: data, encoding: String.Encoding.utf8) {
//
//					UserDefaults.standard.set(dataString, forKey: preferenceId)
//				}
//			}
//		}
//		catch {
//			print("Unable to serialize SpeakerProfile to Json data")
//		}
//	}
	
	func profileFrom(dict: [String:Any]) {
		
		if let identificationProfileId = dict[SpeakerProfile.identificationProfileIdKey] as? String {
			
			var profile = self.profiles.first(where: { $0.identificationProfileId == identificationProfileId })
			
			if profile == nil {
				print("   did not find existing profile in SpeakerProfiles.profiles, creating new profile")
				profile = SpeakerProfile(fromJson: dict)
				self.profiles.append(profile!)
			} else if let profile = profile {
				print("   found existing profile in SpeakerProfiles.profiles, updating values")
				profile.update(fromJson: dict)
			}
		}
	}
	
	func dump () {
		print("SpeakerProfiles: (\(self.profiles.count))")
		for profile in self.profiles {
			print("               : identificationProfileId: \(profile.identificationProfileId?.debugDescription ?? "nil")")
			print("               : locale: \(profile.locale?.debugDescription ?? "nil")")
			print("               : enrollmentSpeechTime: \(profile.enrollmentSpeechTime?.debugDescription ?? "nil")")
			print("               : remainingEnrollmentSpeechTime: \(profile.remainingEnrollmentSpeechTime?.debugDescription ?? "nil")")
			print("               : createdDateTime: \(profile.createdDateTime?.debugDescription ?? "nil")")
			print("               : lastActionDateTime: \(profile.lastActionDateTime?.debugDescription ?? "nil")")
			print("               : enrollmentStatus: \(profile.enrollmentStatus?.rawValue ?? "nil")")
		}
	}
}

class SpeakerProfile {
	
	private	var _isoFormatter: ISO8601DateFormatter?
	var isoFormatter: ISO8601DateFormatter? {
		if _isoFormatter == nil {
			_isoFormatter = ISO8601DateFormatter()
			_isoFormatter?.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		}
		return _isoFormatter
	}
	
	private	var _dateFormatter: DateFormatter?
	var dateFormatter: DateFormatter? {
		if _dateFormatter == nil {
			_dateFormatter = DateFormatter()
			_dateFormatter?.dateStyle = .short
			_dateFormatter?.timeStyle = .short
		}
		return _dateFormatter
	}
	
	
	static let identificationProfileIdKey = "identificationProfileId"
	static let localeKey = "locale"
	static let enrollmentSpeechTimeKey = "enrollmentSpeechTime"
	static let remainingEnrollmentSpeechTimeKey = "remainingEnrollmentSpeechTime"
	static let createdDateTimeKey = "createdDateTime"
	static let lastActionDateTimeKey = "lastActionDateTime"
	static let enrollmentStatusKey = "enrollmentStatus"
	
	var identificationProfileId: String? // "111f427c-3791-468f-b709-fcef7660fff9",
	var locale: String? = "en-US"
	var enrollmentSpeechTime: Double? // 0.0
	var remainingEnrollmentSpeechTime: Double? // 0.0,
	var createdDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var lastActionDateTime: Date? // "2015-04-23T18:25:43.511Z",
	var enrollmentStatus: SpeakerProfileEnrollmentStatus? // "Enrolled"
	
	var createdDateTimeString: String {
		if let createdDateTime = createdDateTime {
			return dateFormatter?.string(from: createdDateTime) ?? ""
		}
		return ""
	}
	
	var lastActionDateTimeString: String {
		if let lastActionDateTime = lastActionDateTime {
			return dateFormatter?.string(from: lastActionDateTime) ?? ""
		}
		return ""
	}
	
	init(fromJson dict: [String:Any]) {
		if let identificationProfileId = dict[SpeakerProfile.identificationProfileIdKey] as? String {
			self.identificationProfileId = identificationProfileId
		}
		self.update(fromJson: dict)
	}
	
	func update(fromJson dict: [String:Any]) {
//		if let identificationProfileId = dict[SpeakerProfile.identificationProfileIdKey] as? String {
//			self.identificationProfileId = identificationProfileId
//		}
		if let locale = dict[SpeakerProfile.localeKey] as? String{
			self.locale = locale
		}
		if let enrollmentSpeechTime = dict[SpeakerProfile.enrollmentSpeechTimeKey] as? Double {
			self.enrollmentSpeechTime = enrollmentSpeechTime
		}
		if let remainingEnrollmentSpeechTime = dict[SpeakerProfile.remainingEnrollmentSpeechTimeKey] as? Double {
			self.remainingEnrollmentSpeechTime = remainingEnrollmentSpeechTime
		}
		if let createdDateTime = dict[SpeakerProfile.createdDateTimeKey] as? String {
			self.createdDateTime = isoFormatter?.date(from: createdDateTime)
		}
		if let lastActionDateTime = dict[SpeakerProfile.lastActionDateTimeKey] as? String {
			self.lastActionDateTime = isoFormatter?.date(from: lastActionDateTime)
		}
		if let enrollmentStatusString = dict[SpeakerProfile.enrollmentStatusKey] as? String, let enrollmentStatus = SpeakerProfileEnrollmentStatus(rawValue: enrollmentStatusString) {
			self.enrollmentStatus = enrollmentStatus
		}
	}
}

enum SpeakerProfileEnrollmentStatus : String {
	case enrolling = "Enrolling"	// profile is currently enrolling and is not ready for identification
	case training = "Training"		// profile is currently training and is not ready for identification
	case enrolled = "Enrolled"		// profile is currently enrolled and is ready for identification
}
