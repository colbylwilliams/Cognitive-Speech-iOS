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
		// setup code
		return instance
	}()
	
	
	var shortAudio: Bool {
		get { return UserDefaults.standard.bool(forKey: SpeakerPreferenceKeys.shortAudio) }
		set(val) { UserDefaults.standard.set(val, forKey: SpeakerPreferenceKeys.shortAudio) }
	}
	
	
	var selectedProfileType: SpeakerProfileType = SpeakerProfileType(rawValue: UserDefaults.standard.integer(forKey: SpeakerPreferenceKeys.speakerType))!
	
	func setSelectedProfileType(typeInt: Int) {
		if typeInt < 2 {
			if let profileType = SpeakerProfileType(rawValue: typeInt) {
				print("Setting Selected Profile Type to \(profileType.string)")
				UserDefaults.standard.set(typeInt, forKey: SpeakerPreferenceKeys.speakerType)
				selectedProfileType = profileType
				getAllProfiles {}
			}
		}
	}
	
	
	private	var _isoFormatter: ISO8601DateFormatter?
	var isoFormatter: ISO8601DateFormatter? {
		if _isoFormatter == nil {
			_isoFormatter = ISO8601DateFormatter()
			_isoFormatter?.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		}
		return _isoFormatter
	}
	
	
	var profiles: [SpeakerProfile] {
		switch selectedProfileType {
		case .identification:
			return identificationProfiles
		case .verification:
			return verificationProfiles
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
	
	
	func profileFrom(dict: [String:Any]) {
		switch selectedProfileType {
		case .identification:
			identificationProfileFrom(dict: dict)
		case .verification:
			verificationProfileFrom(dict: dict)
		}
	}
	
	func identificationProfileFrom(dict: [String:Any]) {
		if let profileId = dict[SpeakerIdentificationProfile.profileIdKey] as? String {
			print("   (\(profileId)) parsing Identification profile")
			
			if let profile = identificationProfiles.first(where: { $0.profileId == profileId }) {
				print("   (\(profileId)) found existing profile with Id - updating existing profile")
				profile.update(fromJson: dict, isoFormatter: isoFormatter)
			} else {
				print("   (\(profileId)) did not find existing profile with Id - creating new profile")
				let profile = SpeakerIdentificationProfile(fromJson: dict, isoFormatter: isoFormatter)
				identificationProfiles.append(profile)
			}
		}
	}
	
	func verificationProfileFrom(dict: [String:Any]) {
		if let profileId = dict[SpeakerVerificationProfile.profileIdKey] as? String {
			print("   (\(profileId)) parsing Verification profile")
			
			if let profile = verificationProfiles.first(where: { $0.profileId == profileId }) {
				print("   (\(profileId)) found existing profile with Id - updating existing profile")
				profile.update(fromJson: dict, isoFormatter: isoFormatter)
			} else {
				print("   (\(profileId)) did not find existing profile with Id - creating new profile")
				let profile = SpeakerVerificationProfile(fromJson: dict, isoFormatter: isoFormatter)
				verificationProfiles.append(profile)
			}
		}
	}
	
	
	// MARK - Create Profile
	
	func createProfile(callback: @escaping () -> ()) {
		print("Create  \(selectedProfileType.string) Profiles...")
		
		if let url = selectedProfileType == .identification ? SpeakerIdUrl.identificationProfiles.url : SpeakerIdUrl.verificationProfiles.url, let data = try? JSONSerialization.data(withJSONObject: ["locale":"en-us"], options: []) {
			
			var request = createRequest(url: url, method: "POST", contentType: SpeakerIdHeaders.contentTypeValue)
			request.httpBody = data
			
			sendProfileRequest(request: request, callback: callback)
		}
	}
	
	
	// MARK - Get Profile
	
	func getProfile(url: URL, profileId: String, callback: @escaping () -> ()) {
		print("Get  \(selectedProfileType.string) Profiles...")
		
		if let url = selectedProfileType.url.url(withId: profileId) {
			
			let request = createRequest(url: url)
			
			sendProfileRequest(request: request, callback: callback)
		}
	}
	
	
	// MARK - Refresh All Profiles
	
	func refreshAllProfiles(callback: @escaping () -> ()) {
		print("Refresh All \(selectedProfileType.string) Profiles...")
		print("   deleting \(selectedProfileType.string) Profiles from memory")
		
		switch selectedProfileType {
		case .identification:
			identificationProfiles = []
		case .verification:
			verificationProfiles = []
		}
		
		getAllProfiles(callback: callback)
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
	
	
	// MARK - Get All Profiles
	
	func getAllProfiles(callback: @escaping () -> ()) {
		print("Get All \(selectedProfileType.string) Profiles...")
		
		if profiles.count > 0 {
			print("   returning locally cached profiles")
			callback()
			
		} else if !sentEmptyRequest {
		
			if let url = selectedProfileType.url.url {
				print("   no locally cached profiles, querying service for profiles")
				
				let request = createRequest(url: url)
				
				sendProfilesRequest(request: request, callback: callback)
			}
		} else {
			print("   already attempted to get \(selectedProfileType.string) profiles, not going to try again")
			callback()
		}
	}
	
	
	
	// MARK - Requests
	
	func sendProfileRequest(request: URLRequest, callback: @escaping () -> ()) {
		toggleNetworkActivityIndicatorVisible(true)
		URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
			self.toggleNetworkActivityIndicatorVisible(false)
			if let error = error {
				print(error.localizedDescription)
			}
			if let data = data, let profile = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
				if let profile = profile {
					self.profileFrom(dict: profile)
				}
			} else { self.checkForError(inData: data) }
			callback()
		}).resume()
	}
	
	
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
						self.profileFrom(dict: profile)
					}
				}
			} else { self.checkForError(inData: data) }
			callback()
		}).resume()
	}
	
	
	// MARK - Delete Profile
	
	func deleteProfile(profileId: String, callback: @escaping () -> ()) {
		print("Delete \(selectedProfileType.string) Profile (\(profileId))...")
		
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
	
	
	
	
	func resetIdentificationProfile(profileId: String, callback: @escaping () -> ()) {
		print("Reset Identification Profile (\(profileId))...")
		
		if let url = SpeakerIdUrl.identificationProfiles.resetUrl(profileId) {
			
			let request = createRequest(url: url, method: "POST")
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				if let profile = self.identificationProfiles.first(where: { $0.profileId == profileId }) {
					profile.enrollmentSpeechTime = 0.0
					profile.enrollmentStatus = SpeakerProfileEnrollmentStatus.enrolling
				}
				callback()
			}).resume()
		}
	}
	
	
	var timer: Timer!
	
	func createIdentificationProfileEnrollment(fileUrl: URL, callback: @escaping () -> ()) {
		if let profileId = selectedIdentificationProfileId, let url = SpeakerIdUrl.identificationProfiles.enrollUrl(profileId, useShort: shortAudio) {
			print("Create Identification Profile Enrollment (\(profileId))...")
			
//			let request = createRequest(url: url, method: "POST", contentType: SpeakerIdHeaders.contentTypeValue)
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
						self.checkOperationStatus(operationUrl: operationUrl, callback: { r in
							
							print("Finished!")
						})
					})
					
					RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
				} else { self.checkForError(inData: data) }
			}).resume()
		}
	}
	
	func checkForError(inData: Data?) {
		if let data = inData, let json = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
			if let json = json, let error = json["error"] as? [String:Any], let code = error["code"] as? String, let message = error["message"] as? String {
				print("Error: \(code) - \(message)")
			} else if let str = String.init(data: data, encoding: String.Encoding.utf8) {
				print("Error: \(str)")
			}
		}
	}
	
	
	func identifySpeaker(fileUrl: URL, callback: @escaping (SpeakerProfile?) -> ()) {
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
						self.checkOperationStatus(operationUrl: operationUrl, callback: { r in
							if let speakerResult = r.identificationResult, let identifiedProfileId = speakerResult.identifiedProfileId, let speakerProfile = self.identificationProfiles.first(where: {$0.profileId == identifiedProfileId}) {
								callback(speakerProfile)
							} else {
								callback(nil)
							}
							print("Finished!")
						})
					})
					
					RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
				}
			}).resume()
		}
	}
	
	
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
							callback(speakerResult)
						}
					}
				}
			}  else { self.checkForError(inData: opData) }
		}).resume()
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
