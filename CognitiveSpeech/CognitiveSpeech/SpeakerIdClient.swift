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
	
	var speakerProfiles: SpeakerProfiles!
	
	var profiles: [SpeakerProfile] {
		return speakerProfiles.profiles
	}
	
	static let shared: SpeakerIdClient = {
		let instance = SpeakerIdClient()
		// setup code
		instance.speakerProfiles = SpeakerProfiles()
		return instance
	}()
	
	
	func createIdentificationProfile(callback: @escaping () -> ()) {
		print("Create Identification Profile...")
		
		if let url = SpeakerIdUrl.identificationProfiles.url, let data = try? JSONSerialization.data(withJSONObject: ["locale":"en-us"], options: []) {
			
			var request = createRequest(url: url, method: "POST", contentType: SpeakerIdHeaders.contentTypeValue)
			request.httpBody = data
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				if let data = data, let profile = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
					if let profile = profile {
						self.speakerProfiles.profileFrom(dict: profile)
					}
				}
				callback()
			}).resume()
		}
	}
	
	
	func getIdentificationProfile(profileId: String, callback: @escaping () -> ()) {
		print("Get Identification Profile (\(profileId))...")
		
		if let url = SpeakerIdUrl.identificationProfiles.url(withId: profileId) {
			
			let request = createRequest(url: url)
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				if let data = data, let profile = try? JSONSerialization.jsonObject(with: data) as? [String:Any] {
					if let profile = profile {
						self.speakerProfiles.profileFrom(dict: profile)
					}
				}
				callback()
			}).resume()
		}
	}
	
	
	func refreshAllIdentificationProfiles(callback: @escaping () -> ()) {
		print("Refresh All Identification Profiles...")
		
		print("   deleting locally cached profiles")
		speakerProfiles.profiles = []
		getAllIdentificationProfiles(callback: callback)
	}
	
	
	func getAllIdentificationProfiles(callback: @escaping () -> ()) {
		print("Get All Identification Profiles...")
		
		if speakerProfiles.profiles.count > 0 {
			print("   returning locally cached profiles")
			callback()
			
		} else if let url = SpeakerIdUrl.identificationProfiles.url {
			print("   no locally cached profiles, querying service for profiles")
			
			let request = createRequest(url: url)
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [[String:Any]] {
					if let json = json {
						for profile in json {
							self.speakerProfiles.profileFrom(dict: profile)
						}
					}
				}
				callback()
			}).resume()
		}
	}
	
	
	func deleteIdentificationProfile(profileId: String, callback: @escaping () -> ()) {
		print("Delete Identification Profile (\(profileId))...")
		
		if let url = SpeakerIdUrl.identificationProfiles.url(withId: profileId) {
			
			let request = createRequest(url: url, method: "DELETE")
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				if let index = self.speakerProfiles.profiles.index(where: { $0.identificationProfileId == profileId }) {
					self.speakerProfiles.profiles.remove(at: index)
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
				if let profile = self.speakerProfiles.profiles.first(where: { $0.identificationProfileId == profileId }) {
					profile.enrollmentSpeechTime = 0.0
					profile.enrollmentStatus = SpeakerProfileEnrollmentStatus.enrolling
				}
				callback()
			}).resume()
		}
	}
	
	var timer: Timer!
	
	func createIdentificationProfileEnrollment(profileId: String, fileUrl: URL, callback: @escaping () -> ()) {
		print("Create Identification Profile Enrollment (\(profileId))...")
		
		if let url = SpeakerIdUrl.identificationProfiles.enrollUrl(profileId, useShort: true) {
			
			let request = createRequest(url: url, method: "POST", contentType: SpeakerIdHeaders.contentTypeValue)
			
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
				}
			}).resume()
		}
	}
	
	
	func checkOperationStatus(operationUrl: URL, callback: @escaping (SpeakerOperationResult) -> ()) {
		print("Checking operation status...")
		
		var oppRequest = URLRequest(url: operationUrl)
		oppRequest.addValue(SpeakerIdHeaders.subscriptionValue, forHTTPHeaderField: SpeakerIdHeaders.subscriptionKey)
		
		self.toggleNetworkActivityIndicatorVisible(true)
		URLSession.shared.dataTask(with: oppRequest, completionHandler: { (opData, opResponse, opError) in
			self.toggleNetworkActivityIndicatorVisible(false)
			if let opError = opError {
				print(opError.localizedDescription)
			}
			if let opData = opData, let opJson = try? JSONSerialization.jsonObject(with: opData) as? [String:Any] {
				if let opJson = opJson {
					let speakerResult = SpeakerOperationResult(fromJson: opJson)
					if let speakerStatus = speakerResult.status {
						if speakerStatus == .succeeded || speakerStatus == .failed {
							self.timer.invalidate()
							self.timer = nil
							callback(speakerResult)
						}
					}
				}
			}
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
	
	func printProfiles () {
		speakerProfiles.dump()
	}
}
