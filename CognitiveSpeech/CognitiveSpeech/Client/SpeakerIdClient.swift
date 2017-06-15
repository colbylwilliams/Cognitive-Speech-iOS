//
//  SpeakerIdClient.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit
import Foundation

class SpeakerIdClient : NSObject {
	
	static let shared: SpeakerIdClient = {
		let instance = SpeakerIdClient()
		return instance
	}()
	
	private	var _isoFormatter: ISO8601DateFormatter?
	var isoFormatter: ISO8601DateFormatter? {
		if _isoFormatter == nil {
			_isoFormatter = ISO8601DateFormatter()
			_isoFormatter?.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		}
		return _isoFormatter
	}
	
	var verificationPhrases: [String] = []
	
	var shortAudio: Bool {
		get { return UserDefaults.standard.bool(forKey: SpeakerPreferenceKeys.shortAudio) }
		set(val) { UserDefaults.standard.set(val, forKey: SpeakerPreferenceKeys.shortAudio) }
	}
	
	var selectedProfileType: SpeakerProfileType = SpeakerProfileType(rawValue: UserDefaults.standard.integer(forKey: SpeakerPreferenceKeys.speakerType))!
	
	func setSelectedProfileType(typeInt: Int, callback: (() -> ())? = nil) {
		if typeInt < 2 {
			if let profileType = SpeakerProfileType(rawValue: typeInt) {
				print("Setting Selected Profile Type to \(profileType.string)")
				UserDefaults.standard.set(typeInt, forKey: SpeakerPreferenceKeys.speakerType)
				selectedProfileType = profileType
				getAllProfiles {
					if let cb = callback {
						cb()
					}
				}
			}
		}
	}
	
	
	// MARK - Profiles
	
	var profiles: [SpeakerProfile] {
		switch selectedProfileType {
		case .identification:
			return identificationProfiles
		case .verification:
			return verificationProfiles
		}
	}
	
	var identificationProfiles: [SpeakerIdentificationProfile] = [] {
		// willSet(newValue) {	print("Profiles WillSet") }
		didSet {
			// print("Profiles DidSet")
			if let _ = identificationProfiles.first(where: { $0.profileId == selectedIdentificationProfileId }) {
				
			} else if identificationProfiles.count > 0 {
				selectedIdentificationProfileId = identificationProfiles.first?.profileId
			} else {
				selectedIdentificationProfileId = nil
			}
		}
	}
	
	var verificationProfiles: [SpeakerVerificationProfile] = [] {
		// willSet(newValue) {	print("Profiles WillSet") }
		didSet {
			// print("Profiles DidSet")
			if let _ = verificationProfiles.first(where: { $0.profileId == selectedVerificationProfileId }) {
				
			} else if verificationProfiles.count > 0 {
				selectedVerificationProfileId = verificationProfiles.first?.profileId
			} else {
				selectedVerificationProfileId = nil
			}
		}
	}
	
	
	// MARK - Selected Profile
	
	var selectedProfile: SpeakerProfile? {
		switch selectedProfileType {
		case .identification:
			return selectedIdentificationProfile
		case .verification:
			return selectedVerificationProfile
		}
	}
	
	var selectedIdentificationProfile: SpeakerIdentificationProfile? {
		if let profileId = selectedIdentificationProfileId, let profile = identificationProfiles.first(where: { $0.profileId == profileId }) {
			return profile
		}
		return nil
	}
	
	var selectedVerificationProfile: SpeakerVerificationProfile? {
		if let profileId = selectedVerificationProfileId, let profile = verificationProfiles.first(where: { $0.profileId == profileId }) {
			return profile
		}
		return nil
	}
	
	func isSelectedProfile(_ profileId: String) -> Bool {
		return profileId == selectedProfileId
	}
	
	func selectedProfileIndex() -> Int? {
		if let profileId = selectedProfileId {
			return profiles.index(where: { $0.profileId == profileId })
		}
		return nil
	}
	
	
	// MARK - Selected Profile ID
	
	private var selectedProfileId: String? {
		get {
			switch selectedProfileType {
			case .identification:
				return selectedIdentificationProfileId
			case .verification:
				return selectedVerificationProfileId
			}
		}
		set (newVal) {
			switch selectedProfileType {
			case .identification:
				selectedIdentificationProfileId = newVal
			case .verification:
				selectedVerificationProfileId = newVal
			}
		}
	}
	
	private var selectedIdentificationProfileId: String? {
		get { return UserDefaults.standard.string(forKey: SpeakerPreferenceKeys.selectedIdentificationProfileId) }
		set(newVal) { UserDefaults.standard.setValue(newVal, forKey: SpeakerPreferenceKeys.selectedIdentificationProfileId) }
	}

	private var selectedVerificationProfileId: String? {
		get { return UserDefaults.standard.string(forKey: SpeakerPreferenceKeys.selectedVerificationProfileId) }
		set(newVal) { UserDefaults.standard.setValue(newVal, forKey: SpeakerPreferenceKeys.selectedVerificationProfileId) }
	}
	
	
	// MARK - Select Profile By Index
	
	func selectProfile(byIndex index: Int) {
		switch selectedProfileType {
		case .identification:
			selectIdentificationProfile(byIndex: index)
		case .verification:
			selectVerificationProfile(byIndex: index)
		}
	}

	private func selectIdentificationProfile(byIndex index: Int) {
		if index < identificationProfiles.count, let selectedId = identificationProfiles[index].profileId {
			selectedIdentificationProfileId = selectedId
		} else {
			selectedIdentificationProfileId = nil
		}
	}

	private func selectVerificationProfile(byIndex index: Int) {
		if index < verificationProfiles.count, let selectedId = verificationProfiles[index].profileId {
			selectedVerificationProfileId = selectedId
		} else {
			selectedVerificationProfileId = nil
		}
	}
	
	
	var sentEmptyRequest: Bool {
		switch selectedProfileType {
		case .identification:
			let sent = sentIdentificationEmptyRequest
			sentIdentificationEmptyRequest = true
			return sent
		case .verification:
			let sent = sentVerificationEmptyRequest
			sentVerificationEmptyRequest = true
			return sent
		}
	}
	var sentIdentificationEmptyRequest = false
	var sentVerificationEmptyRequest = false
	
	
	// MARK - Profile From Data
	
	func profileFrom(profileName name: String? = nil, dict: [String:Any]?) -> SpeakerProfile? {
		switch selectedProfileType {
		case .identification:
			return identificationProfileFrom(profileName: name, dict: dict)
		case .verification:
			return verificationProfileFrom(profileName: name, dict: dict)
		}
	}
	
	func identificationProfileFrom(profileName: String? = nil, dict: [String:Any]?) -> SpeakerIdentificationProfile? {
		if let dict = dict, let profileId = dict[SpeakerIdentificationProfile.profileIdKey] as? String ?? selectedIdentificationProfileId {
			print("   (\(profileId)) parsing Identification profile")
			
			var name = profileName
			
			if name == nil {
				name = UserDefaults.standard.string(forKey: SpeakerPreferenceKeys.nameForProfileId(profileId: profileId))
			} else{
				UserDefaults.standard.set(name, forKey: SpeakerPreferenceKeys.nameForProfileId(profileId: profileId))
			}
			
			if let profile = identificationProfiles.first(where: { $0.profileId == profileId }) {
				print("   (\(profileId)) found existing profile with Id - updating existing profile")
				profile.update(fromJson: dict, isoFormatter: isoFormatter)
				return profile
			} else {
				print("   (\(profileId)) did not find existing profile with Id - creating new profile")
				let profile = SpeakerIdentificationProfile(fromJson: dict, name: name, isoFormatter: isoFormatter)
				identificationProfiles.append(profile)
				return profile
			}
		}
		return nil
	}
	
	func verificationProfileFrom(profileName: String? = nil, dict: [String:Any]?) -> SpeakerVerificationProfile? {
		if let dict = dict, let profileId = dict[SpeakerVerificationProfile.profileIdKey] as? String ?? selectedVerificationProfileId {
			print("   (\(profileId)) parsing Verification profile")
			
			var name = profileName
			
			if name == nil {
				name = UserDefaults.standard.string(forKey: SpeakerPreferenceKeys.nameForProfileId(profileId: profileId))
			} else{
				UserDefaults.standard.set(name, forKey: SpeakerPreferenceKeys.nameForProfileId(profileId: profileId))
			}
			
			if let profile = verificationProfiles.first(where: { $0.profileId == profileId }) {
				print("   (\(profileId)) found existing profile with Id - updating existing profile")
				profile.update(fromJson: dict, isoFormatter: isoFormatter)
				return profile
			} else {
				print("   (\(profileId)) did not find existing profile with Id - creating new profile")
				let profile = SpeakerVerificationProfile(fromJson: dict, name: name, isoFormatter: isoFormatter)
				verificationProfiles.append(profile)
				return profile
			}
		}
		return nil
	}
	
	
	// MARK - Get Initial Config
	
	func getConfig(callback: @escaping () -> ()) {
		
		var getAllProfilesCallback = false
		var getVerificationPhrasesCallback = false
		
		func checkCallbacks() {
			print("checkCallbacks - getAllProfilesCallback: \(getAllProfilesCallback)  getVerificationPhrasesCallback: \(getVerificationPhrasesCallback)")
			if getAllProfilesCallback && getVerificationPhrasesCallback {
				print("checkCallbacks - firing callback")
				callback()
			}
		}
		
		getAllProfiles {
			print("getAllProfiles finished")
			getAllProfilesCallback = true
			checkCallbacks()
		}
		getVerificationPhrases {
			getVerificationPhrasesCallback = true
			checkCallbacks()
		}
	}
	
	
	// MARK - Create Profile
	
	func createProfile(profileName name: String, callback: @escaping () -> ()) {
		print("Create  \(selectedProfileType.string) Profiles...")
		
		if let url = selectedProfileType == .identification ? SpeakerIdUrl.identificationProfiles.url : SpeakerIdUrl.verificationProfiles.url, let data = try? JSONSerialization.data(withJSONObject: ["locale":"en-us"], options: []) {
			
			var request = createRequest(url: url, method: "POST", contentType: SpeakerIdHeaders.contentTypeValue)
			request.httpBody = data
			
			sendProfileRequest(request: request, profileName: name) { partialProfile in
				if let partialProfile = partialProfile {
					self.getProfile(profileId: partialProfile.profileId, callback: { completeProfile in
						if let completeProfile = completeProfile {
							self.selectedProfileId = completeProfile.profileId
							callback()
						} else { callback() }
					})
				} else { callback() }
			}
		}
	}
	
	
	// MARK - Get Profile
	
	func getProfile(profileId: String,  callback: @escaping (SpeakerProfile?) -> ()) {
		print("Get  \(selectedProfileType.string) Profiles...")
		
		if let url = selectedProfileType.url.url(withId: profileId) {
			
			let request = createRequest(url: url)
			
			sendProfileRequest(request: request, callback: callback)
		}
	}
	
	
	// MARK - Send Profle Request
	
	func sendProfileRequest(request: URLRequest, profileName name: String? = nil, callback: @escaping (SpeakerProfile?) -> ()) {
		toggleNetworkActivityIndicatorVisible(true)
		URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			self.toggleNetworkActivityIndicatorVisible(false)
			if let error = error {
				print(error.localizedDescription)
			}
			if let data = data, let profileData = try? JSONSerialization.jsonObject(with: data) as? [String:Any], let profile = self.profileFrom(profileName: name, dict: profileData) {
				callback(profile)
			} else {
				self.checkForError(inData: data)
				callback(nil)
			}
		}).resume()
	}
	
	
	// MARK - Refresh All Profiles
	
	func refreshAllProfiles(callback: @escaping () -> ()) {
		print("Refresh All \(selectedProfileType.string) Profiles...")
		print("   deleting \(selectedProfileType.string) Profiles from memory")
		
		let cachedId = selectedProfileId
		
		switch selectedProfileType {
		case .identification:
			identificationProfiles = []
		case .verification:
			verificationProfiles = []
		}
		
		getAllProfiles(forceRefresh: true, selectedId: cachedId, callback: callback)
	}
	
	
	// MARK - Get All Profiles
	
	func getAllProfiles(forceRefresh: Bool? = nil, selectedId: String? = nil, callback: @escaping () -> ()) {
		print("Get All \(selectedProfileType.string) Profiles...")
		
		let force = forceRefresh ?? false
		
		if profiles.count > 0 {
			print("   returning locally cached profiles")
			callback()
			
		} else if force || !sentEmptyRequest {
		
			if let url = selectedProfileType.url.url {
				print("   no locally cached profiles, querying service for profiles")
				
				let request = createRequest(url: url)
				
				// Cache selected profileId
				let cacheSelectedId = selectedId ?? selectedProfileId
				
				sendProfilesRequest(request: request) {
					// Persist the selected profileId
					if let cachedId = cacheSelectedId, let _ = self.profiles.first(where: { $0.profileId == cachedId }) {
						self.selectedProfileId = cachedId
					}
					callback()
				}
			}
		} else {
			print("   already attempted to get \(selectedProfileType.string) profiles, not going to try again")
			callback()
		}
	}
	
	
	// MARK - Send Profles Request
	
	func sendProfilesRequest(request: URLRequest, callback: @escaping () -> ()) {
		toggleNetworkActivityIndicatorVisible(true)
		URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			self.toggleNetworkActivityIndicatorVisible(false)
			if let error = error {
				print(error.localizedDescription)
			}
			if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [[String:Any]] {
				if let json = json {
					for profile in json {
						let _ = self.profileFrom(dict: profile)
					}
				}
			} else { self.checkForError(inData: data) }
			callback()
		}).resume()
	}
	
	
	// MARK - Delete Profile
	
	func deleteProfile(profileId: String, callback: @escaping () -> ()) {
		print("Delete \(selectedProfileType.string) Profile (\(profileId))...")
		
		if selectedProfileId == profileId { selectedProfileId = nil	}
		
		if let url = selectedProfileType.url.url(withId: profileId) {
			
			let request = createRequest(url: url, method: "DELETE")
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				switch self.selectedProfileType {
				case .identification:
					if let index = self.identificationProfiles.index(where: { $0.profileId == profileId }) {
						self.identificationProfiles.remove(at: index)
					}
				case .verification:
					if let index = self.verificationProfiles.index(where: { $0.profileId == profileId }) {
						self.verificationProfiles.remove(at: index)
					}
				}
				callback()
			}).resume()
		}
	}
	
	
	// MARK - Reset Enrollment
	
	func resetProfileEnrollment(profileId: String? = nil, callback: @escaping () -> ()) {
		
		if let profileId = profileId ?? selectedProfileId {
		
			print("Reset \(selectedProfileType.string) Profile (\(profileId))...")
		
			if let url = selectedProfileType.url.resetUrl(profileId) {
				
				let request = createRequest(url: url, method: "POST")
				
				toggleNetworkActivityIndicatorVisible(true)
				URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
					self.toggleNetworkActivityIndicatorVisible(false)
					if let error = error {
						print(error.localizedDescription)
					}
					if let profile = self.profiles.first(where: { $0.profileId == profileId }) {
						profile.reset()
					}
					callback()
				}).resume()
			}
		}
	}
	
	
	// MARK - Get Verification Phrases
	
	func getVerificationPhrases(callback: @escaping () -> ()) {
		print("Get Verification Phrases...")
		
		if verificationPhrases.count > 0 {
			print("   returning locally cached phrases")
			callback()
			
		} else if let url = SpeakerIdUrl.verificationPhrases.url(withLocale: "en-us") {
			
			let request = createRequest(url: url)
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				if let data = data, let phraseList = try? JSONSerialization.jsonObject(with: data) as? [[String:String]] {
					if let phraseList = phraseList {
						for phraseObj in phraseList {
							if let phrase = phraseObj["phrase"] {
								print("   adding phrase: \(phrase)")
								self.verificationPhrases.append(phrase)
							}
						}
					}
				}
				callback()
			}).resume()
		}
	}
	
	
	// MARK - Profile Enrollment
	
	var timer: Timer!
	
	func createProfileEnrollment(fileUrl: URL, callback: @escaping () -> ()) {
		if let profileId = selectedProfileId, let url = selectedProfileType.url.enrollUrl(profileId, useShort: shortAudio) {
			print("Create \(selectedProfileType.string) Profile Enrollment (\(profileId))...")
			
			let request = createRequest(url: url, method: "POST")
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.uploadTask(with: request, fromFile: fileUrl, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if error != nil {
					print(error!.localizedDescription)
				}
				switch self.selectedProfileType {
				case .identification:
					
					if let httpResponse = response as? HTTPURLResponse, let operationLocation = httpResponse.allHeaderFields["Operation-Location"] as? String, let operationUrl = URL(string: operationLocation) {
						
						print("Setting up Timer...")
						self.timer = Timer.init(timeInterval: 2, repeats: true, block: { _ in
							self.checkOperationStatus(operationUrl: operationUrl, callback: { result in
								if let speakerResult = result.processingResult {
									let _ = self.profileFrom(dict: speakerResult)
									callback()
								}
							})
						})
						
						RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
					} else {
						self.checkForError(inData: data)
						callback()
					}
					
				case .verification:
					
					if let data = data, let result = try? JSONSerialization.jsonObject(with: data) as? [String:Any], let verificationResult = SpeakerVerificationEnrollmentResult(fromJson: result) {
						print("verificationResult: status:\(verificationResult.enrollmentStatus?.rawValue ?? "nil"), enrollmentsCount: \(verificationResult.enrollmentsCount ?? -1), remainingEnrollments: \(verificationResult.remainingEnrollments ?? -1), phrase: \(verificationResult.phrase ?? "none")")
						let _ = self.profileFrom(dict: result!)
					} else {
						self.checkForError(inData: data)
					}
					callback()
				}
				
			}).resume()
		}
	}
	
	
	// MARK - Identify Speaker
	
	func identifySpeaker(fileUrl: URL, callback: @escaping (SpeakerOperationResult?, SpeakerProfile?) -> ()) {
		print("Identifying Speaker...")
		
		if let url = SpeakerIdUrl.identify.identifyUrl(useShort: shortAudio, profileIds: identificationProfiles.map { $0.profileId }) {
			
			let request = createRequest(url: url, method: "POST")
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.uploadTask(with: request, fromFile: fileUrl, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if error != nil {
					print(error!.localizedDescription)
				}
				if let httpResponse = response as? HTTPURLResponse, let operationLocation = httpResponse.allHeaderFields["Operation-Location"] as? String, let operationUrl = URL(string: operationLocation) {
					
					print("Setting up Timer...")
					
					self.timer = Timer.init(timeInterval: 2, repeats: true, block: { _ in
						self.checkOperationStatus(operationUrl: operationUrl, callback: { result in
							print("Finished!")
							if let speakerResult = result.identificationResult, let identifiedProfileId = speakerResult.identifiedProfileId, let speakerProfile = self.identificationProfiles.first(where: {$0.profileId == identifiedProfileId}) {
								callback(result, speakerProfile)
							} else {
								callback(result, nil)
							}
						})
					})
					
					RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
					
				} else {
					self.checkForError(inData: data)
					callback(nil, nil)
				}
			}).resume()
		}
	}
	
	
	// MARK - Verify Speaker
	
	func verifySpeaker(fileUrl: URL, callback: @escaping (SpeakerVerificationResult?) -> ()) {
		print("Verifying Speaker...")
		
		if let profileId = selectedProfileId, let url = SpeakerIdUrl.verify.verifyUrl(profileId: profileId) {
			
			let request = createRequest(url: url, method: "POST")
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.uploadTask(with: request, fromFile: fileUrl, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if error != nil {
					print(error!.localizedDescription)
				}
				if let data = data, let result = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
					if let result = result {
						let verificationResult = SpeakerVerificationResult(fromJson: result)
						print(verificationResult)
						callback(verificationResult)
					}
				} else {
					self.checkForError(inData: data)
					callback(nil)
				}
			}).resume()
		}
	}
	
	
	// MARK - Check Operation Status
	
	func checkOperationStatus(operationUrl: URL, callback: @escaping (SpeakerOperationResult) -> ()) {
		print("Checking operation status...")
		
		let request = createRequest(url: operationUrl)
		
		self.toggleNetworkActivityIndicatorVisible(true)
		URLSession.shared.dataTask(with: request, completionHandler: { (opData, opResponse, opError) in
			self.toggleNetworkActivityIndicatorVisible(false)
			if let opError = opError {
				print(opError.localizedDescription)
			}
			if let opData = opData, let opJson = try? JSONSerialization.jsonObject(with: opData) as? [String:Any] {
				if let opJson = opJson {
					let speakerResult = SpeakerOperationResult(fromJson: opJson, isoFormatter: self.isoFormatter)
					if let speakerStatus = speakerResult.status {
						if speakerStatus == .succeeded || speakerStatus == .failed {
							self.timer.invalidate()
							self.timer = nil
							let _ = self.profileFrom(dict: opJson)
							callback(speakerResult)
						}
					}
				}
			}  else { self.checkForError(inData: opData) }
		}).resume()
	}
	
	
	// MARK - Error Handling
	
	func checkForError(inData: Data?) {
		if let data = inData, let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
			if let json = json, let error = json["error"] as? [String:Any], let code = error["code"] as? String, let message = error["message"] as? String {
				print("Error: \(code) - \(message)")
			} else if let str = String.init(data: data, encoding: String.Encoding.utf8) {
				print("Error: \(str)")
			}
		}
	}
	
	
	func createRequest(url: URL, method: String = "GET", contentType: String = "") -> URLRequest {
		var request = URLRequest(url: url)
		request.httpMethod = method
		
		if !contentType.isEmpty {
			request.addValue(contentType, forHTTPHeaderField: "Content-Type")
		}
		
		request.addValue(SpeakerIdHeaders.subscriptionValue, forHTTPHeaderField: SpeakerIdHeaders.subscriptionKey)
		
		return request
	}
	
	func toggleNetworkActivityIndicatorVisible(_ visible: Bool){
		DispatchQueue.main.async {
			UIApplication.shared.isNetworkActivityIndicatorVisible = visible
		}
	}	
}
