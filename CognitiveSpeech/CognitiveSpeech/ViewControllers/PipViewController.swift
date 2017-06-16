//
//  PipViewController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit
import AVFoundation

struct PipStrings {
	static let recording = "Recording..."
	static let initializing = "Initializing..."
	static let identifying = "Identifying..."
	static let processing = "Processing..."
	static let verifying = "Verifying..."
	static let training = "Training..."
	static let touchToStop = "Touch anywhere to finish recording."
	static let touchToDismiss = "Touch anywhere to dismiss."
}

class PipViewController: UIViewController, AVAudioRecorderDelegate {
	
	@IBOutlet weak var auxLabel: UILabel!
	@IBOutlet weak var feedbackLabel: UILabel!
	@IBOutlet weak var feedbackDetailLabel: UILabel!
	@IBOutlet weak var backgroundView: UIVisualEffectView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var feedbackLabelVerticalConstraint: NSLayoutConstraint!
	@IBOutlet weak var activityIdnicatorOffsetConstraint: NSLayoutConstraint!
	
	var audioRecorder: AVAudioRecorder?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		backgroundView.layer.cornerRadius = 5
		backgroundView.layer.masksToBounds = true
		
		updateFeedback(feedbackLabel: PipStrings.initializing)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		startRecording()
	}
	
	
	@IBAction func viewTouched(_ sender: Any) {
		if audioRecorder != nil && audioRecorder!.isRecording {
			finishRecording(success: true)
		} else if !activityIndicator.isAnimating {
			updateAndDismiss()
		}
	}
	
	
	func startRecording() {
		print("Start recording...")
		
		let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
		
		let settings = [
			AVFormatIDKey: Int(kAudioFormatLinearPCM),	// Encoding PCM
			AVSampleRateKey: 16000,						// Rate 16K
			AVNumberOfChannelsKey: 1,					// Channels Mono
			AVEncoderBitRateKey: 16,					// Sample Format 16 bit
			AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
		]
		
		do {
			audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
			audioRecorder?.delegate = self
			audioRecorder?.record()
			
			updateFeedback(feedbackLabel: PipStrings.recording, auxLabel: PipStrings.touchToStop)
			
		} catch let error as NSError {
			print("audioSession error: \(error.localizedDescription)")
			finishRecording(success: false)
		}
	}
	
	func finishRecording(success: Bool) {
		print("Stop recording...")
		updateFeedback(feedbackLabel: PipStrings.processing)
		audioRecorder?.stop()
		//  audioRecorder = nil
		
		if success {
			print("Recording succeeded")
		} else {
			print("Recording failed")
		}
	}
	
	
	func updateFeedback(activityIndicator activity: Bool = true, feedbackLabel feedback: String, detailLabel detail: String? = nil, auxLabel aux: String? = nil) {
		if activity != activityIndicator.isAnimating {
			if activity {
				activityIndicator.startAnimating()
			} else {
				activityIndicator.stopAnimating()
			}
			activityIndicator.isHidden = !activity
			activityIdnicatorOffsetConstraint.constant = activity ? 9 : 0
		}
		
		auxLabel.text = aux
		feedbackLabel.text = feedback
		feedbackDetailLabel.text = detail
		
		if feedback == PipStrings.recording {
			activityIndicator.color = UIColor.red
			feedbackLabel.textColor = UIColor.red
		} else {
			activityIndicator.color = UIColor.white
			feedbackLabel.textColor = UIColor.white
		}
		
		feedbackLabelVerticalConstraint.constant = detail == nil ? 0 : 14
	}
	
	
	// MARK: - AVAudioRecorderDelegate
	
	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
		print("Audio Recorder Encode Error: \(error?.localizedDescription ?? "")")
	}
	
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		print("Audio Recorder finished recording (\(flag ? "successfully" : "unsuccessfully"))")
		if flag {
			if SpeakerIdClient.shared.selectedProfile?.enrollmentStatus == .enrolled {
				switch SpeakerIdClient.shared.selectedProfileType {
				case .identification:
					identifySpeaker(fileUrl: recorder.url)
				case .verification:
					verifySpeaker(fileUrl: recorder.url)
				}
			} else {
				enrollSpeaker(fileUrl: recorder.url)
			}
		} else {
			self.updateFeedback(activityIndicator: false, feedbackLabel: "Recording Error", auxLabel: PipStrings.touchToDismiss)
		}
	}
	
	func identifySpeaker(fileUrl url: URL) {
		updateFeedback(feedbackLabel: PipStrings.identifying)
		SpeakerIdClient.shared.identifySpeaker(fileUrl: url, callback: { (result, profile) in
			let details = result?.identificationResultDetails(profileName: profile?.name)
			DispatchQueue.main.async {
				self.updateFeedback(activityIndicator: false, feedbackLabel: details?.title ?? "Unknown error", detailLabel: details?.detail, auxLabel: PipStrings.touchToDismiss)
			}
		})
	}
	
	func verifySpeaker(fileUrl url: URL) {
		updateFeedback(feedbackLabel: PipStrings.verifying)
		SpeakerIdClient.shared.verifySpeaker(fileUrl: url, callback: { result in
			let details = result?.verificationResultDetails
			DispatchQueue.main.async {
				self.updateFeedback(activityIndicator: false, feedbackLabel: details?.title ?? "Unknown error", detailLabel: details?.detail, auxLabel: PipStrings.touchToDismiss)
			}
		})
	}
	
	func enrollSpeaker(fileUrl url: URL) {
		updateFeedback(feedbackLabel: PipStrings.training)
		SpeakerIdClient.shared.createProfileEnrollment(fileUrl: url) { message in
			DispatchQueue.main.async {
				if let message = message {
					self.updateFeedback(activityIndicator: false, feedbackLabel: "Error", detailLabel: message, auxLabel: PipStrings.touchToDismiss)
				} else {
					self.updateFeedback(activityIndicator: false, feedbackLabel: "Done!", auxLabel: PipStrings.touchToDismiss)
					self.updateAndDismiss()
				}
			}
		}
	}
	
	func updateAndDismiss() {
		if let navController = self.presentingViewController as? UINavigationController, let startController = navController.viewControllers.first as? StartViewController {
			startController.updateUIforSelectedProfile()
		}
		self.dismiss(animated: true, completion: nil)
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
