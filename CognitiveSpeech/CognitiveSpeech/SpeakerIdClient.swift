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
			
			var request = URLRequest(url: url)
			
			request.httpBody = data
			request.httpMethod = "POST"
			request.addValue(SpeakerIdHeader.contentType.value, forHTTPHeaderField: SpeakerIdHeader.contentType.key)
			request.addValue(SpeakerIdHeader.subscriptionKey.value, forHTTPHeaderField: SpeakerIdHeader.subscriptionKey.key)
			
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
			
			var request = URLRequest(url: url)
			
			request.httpMethod = "GET"
			request.addValue(SpeakerIdHeader.subscriptionKey.value, forHTTPHeaderField: SpeakerIdHeader.subscriptionKey.key)
			
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
			
			var request = URLRequest(url: url)
			
			request.httpMethod = "GET"
			request.addValue(SpeakerIdHeader.subscriptionKey.value, forHTTPHeaderField: SpeakerIdHeader.subscriptionKey.key)
			
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
			
			var request = URLRequest(url: url)
			
			request.httpMethod = "DELETE"
			request.addValue(SpeakerIdHeader.subscriptionKey.value, forHTTPHeaderField: SpeakerIdHeader.subscriptionKey.key)
			
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
			
			var request = URLRequest(url: url)
			
			request.httpMethod = "POST"
			request.addValue(SpeakerIdHeader.subscriptionKey.value, forHTTPHeaderField: SpeakerIdHeader.subscriptionKey.key)
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if let error = error {
					print(error.localizedDescription)
				}
				if let profile = self.speakerProfiles.profiles.first(where: { $0.identificationProfileId == profileId }) {
					profile.enrollmentSpeechTime = 0.0
					profile.enrollmentStatus = "Enrolling"
				}
				callback()
			}).resume()
		}
	}
	
	var timer: Timer!
	
	func createIdentificationProfileEnrollment(profileId: String, fileUrl: URL, callback: @escaping () -> ()) {
		print("Create Identification Profile Enrollment (\(profileId))...")
		
		if let url = SpeakerIdUrl.identificationProfiles.enrollUrl(profileId) {
			
			var request = URLRequest(url: url)
			
			request.httpMethod = "POST"
			request.addValue(SpeakerIdHeader.contentType.value, forHTTPHeaderField: SpeakerIdHeader.contentType.key)
			request.addValue(SpeakerIdHeader.subscriptionKey.value, forHTTPHeaderField: SpeakerIdHeader.subscriptionKey.key)
			
			toggleNetworkActivityIndicatorVisible(true)
			URLSession.shared.uploadTask(with: request, fromFile: fileUrl, completionHandler: { (data, response, error) in
				self.toggleNetworkActivityIndicatorVisible(false)
				if error != nil {
					print(error!.localizedDescription)
				}
				if let httpResponse = response as? HTTPURLResponse, let operationLocation = httpResponse.allHeaderFields["Operation-Location"] as? String, let operationUrl = URL(string: operationLocation) {
					
					print("Setting up Timer...")
					
					self.timer = Timer.init(timeInterval: 2, repeats: true, block: { (t) in
						print("Checking operation status...")
						
						var oppRequest = URLRequest(url: operationUrl)
						oppRequest.addValue(SpeakerIdHeader.subscriptionKey.value, forHTTPHeaderField: SpeakerIdHeader.subscriptionKey.key)
						
						self.toggleNetworkActivityIndicatorVisible(true)
						URLSession.shared.dataTask(with: oppRequest, completionHandler: { (d, r, e) in
							self.toggleNetworkActivityIndicatorVisible(false)
							if e != nil {
								print(e!.localizedDescription)
							}
							if let d = d, let s = try? JSONSerialization.jsonObject(with: d) as? [String:Any] {
								if let s = s, let status = s["status"] as? String {
									print("   status: \(status)")
									if status == "failed" || status == "succeeded" {
										self.timer.invalidate()
										callback()
									}
								}
							}
						}).resume()
					})
					
					RunLoop.main.add(self.timer, forMode: RunLoopMode.commonModes)
				}
			}).resume()
		}
	}
	
	var opUrl: URL!
	
	@objc func checkOperation() {
		print("Checking operation status...")
		self.toggleNetworkActivityIndicatorVisible(true)
		URLSession.shared.dataTask(with: opUrl, completionHandler: { (d, r, e) in
			self.toggleNetworkActivityIndicatorVisible(false)
			if e != nil {
				print(e!.localizedDescription)
			}
			if let d = d, let s = try? JSONSerialization.jsonObject(with: d) as? [String:Any] {
				if let s = s, let status = s["status"] as? String {
					print("Status: \(status)")
					if status == "failed" || status == "succeeded" {
						self.timer.invalidate()
					}
				}
			}
		}).resume()
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
