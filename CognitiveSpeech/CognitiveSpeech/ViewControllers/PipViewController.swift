//
//  PipViewController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit
import AVFoundation

class PipViewController: UIViewController, AVAudioRecorderDelegate {

	@IBOutlet weak var backgroundView: UIVisualEffectView!
	@IBOutlet weak var feedbackLabel: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	var audioRecorder: AVAudioRecorder?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		backgroundView.layer.cornerRadius = 5
		backgroundView.layer.masksToBounds = true
		
		feedbackLabel.text = "Initializing..."
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		startRecording()
	}
	
	
	@IBAction func viewTouched(_ sender: Any) {
		finishRecording(success: true)
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
			
			feedbackLabel.text = "Recording..."
			
		} catch let error as NSError {
			print("audioSession error: \(error.localizedDescription)")
			finishRecording(success: false)
		}
	}
	
	
	func finishRecording(success: Bool) {
		print("Stop recording...")
		
		audioRecorder?.stop()
		//  audioRecorder = nil
		
		if success {
			print("Recording succeeded")
		} else {
			print("Recording failed")
		}
	}
	
	
	// MARK: - AVAudioRecorderDelegate
	
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		print("Audio Recorder finished recording: successful: \(flag)")
		feedbackLabel.text = "Processing..."
		if !flag {
			finishRecording(success: false)
			dismiss(animated: true, completion: nil)
		} else { 
			if SpeakerIdClient.shared.selectedProfile?.enrollmentStatus == .enrolled {
				switch SpeakerIdClient.shared.selectedProfileType {
				case .identification:
					SpeakerIdClient.shared.identifySpeaker(fileUrl: recorder.url, callback: { (result, profile) in
						DispatchQueue.main.async {
							let alert = UIAlertController(title: profile?.name ?? result?.status?.rawValue ?? "unknown", message: result?.message ?? "", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
								self.updateAndDismiss()
							}))
							self.present(alert, animated: true, completion: nil)
						}
					})
				case .verification:
					SpeakerIdClient.shared.verifySpeaker(fileUrl: recorder.url, callback: { result in
						DispatchQueue.main.async {
							let alert = UIAlertController(title: result?.result?.rawValue ?? "unknown", message: "confidence: \(result?.confidence?.rawValue ?? "")", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { action in
								self.updateAndDismiss()
							}))
							self.present(alert, animated: true, completion: nil)
						}
					})
				}
			} else {
				SpeakerIdClient.shared.createProfileEnrollment(fileUrl: recorder.url) {
					DispatchQueue.main.async {
						self.updateAndDismiss()
					}
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
	
	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
		print("Audio Recorder Encode Error: \(error?.localizedDescription ?? "")")
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
