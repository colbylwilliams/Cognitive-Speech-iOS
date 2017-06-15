//
//  StartViewController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit
import AVFoundation

class StartViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
	
	var recordingSession: AVAudioSession?
	var audioRecorder: AVAudioRecorder?
	var audioPlayer: AVAudioPlayer?
	
	@IBOutlet weak var profileTitleLabel: UILabel!
	@IBOutlet weak var profileIdLabel: UILabel!
	@IBOutlet weak var profileStatusLabel: UILabel!
	@IBOutlet weak var profileCreatedLabel: UILabel!
	@IBOutlet weak var profileUpdatedLabel: UILabel!
	@IBOutlet weak var profileRemainingLabel: UILabel!
	@IBOutlet weak var profileTimeCountLabel: UILabel!
	
	@IBOutlet weak var talkButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var shortAudioButton: UIBarButtonItem!
	
	private	var _dateFormatter: DateFormatter?
	var dateFormatter: DateFormatter? {
		if _dateFormatter == nil {
			_dateFormatter = DateFormatter()
			_dateFormatter?.dateStyle = .short
			_dateFormatter?.timeStyle = .short
		}
		return _dateFormatter!
	}
	
	
	@IBAction func talkButtonTouchStarted(_ sender: Any) {
		print("Start recording...")
		startRecording()
    }
	
	@IBAction func talkButtonTouchEnded(_ sender: Any) {
		print("Stop recording...")
		finishRecording(success: true)
	}
	
	@IBAction func playButtonTouched(_ sender: Any) {
		print("Play recording...")
		playRecording()
	}
	
	@IBAction func shortAudioButtonTouched(_ sender: Any) {
		SpeakerIdClient.shared.shortAudio = !SpeakerIdClient.shared.shortAudio
		shortAudioButton.title = SpeakerIdClient.shared.shortAudio ? "short" : "long"
	}
	
	@IBOutlet weak var speakerTypeSegmentedControl: UISegmentedControl!
	
	@IBAction func speakerTypeSegmentedControlChanged(_ sender: Any) {
		SpeakerIdClient.shared.setSelectedProfileType(typeInt: speakerTypeSegmentedControl.selectedSegmentIndex) {
			DispatchQueue.main.async {
				self.updateUIforSelectedProfile()
			}
		}
	}
	
	@IBAction func unwind(segue:UIStoryboardSegue) { }
	
	override func viewDidLoad() {
		
        super.viewDidLoad()
		
		playButton.layer.cornerRadius = 6
		talkButton.layer.cornerRadius = 6
		
		playButton.isEnabled = false
		talkButton.isEnabled = false
		
		shortAudioButton.title = SpeakerIdClient.shared.shortAudio ? "short" : "long"
		
		speakerTypeSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: SpeakerPreferenceKeys.speakerType)
		
		SpeakerIdClient.shared.getConfig {
			
			self.recordingSession = AVAudioSession.sharedInstance()
			
			do {
				try self.recordingSession?.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
				try self.recordingSession?.setActive(true)
				
				self.recordingSession?.requestRecordPermission() { [unowned self] allowed in
					DispatchQueue.main.async {
						self.updateUIforSelectedProfile(recordingAllowed: allowed)
					}
				}
			} catch let error as NSError {
				print("audioSession error: \(error.localizedDescription)")
			}
		}
    }
	
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		updateUIforSelectedProfile()
	}
	
	
	func updateUIforSelectedProfile(recordingAllowed: Bool? = nil) {
		
		let allowed = recordingAllowed ?? (recordingSession?.recordPermission() == .granted) ?? false
		
		playButton.isEnabled = allowed
		talkButton.isEnabled = allowed
		
		let title = SpeakerIdClient.shared.selectedProfile?.enrollmentStatus == .enrolled ? SpeakerIdClient.shared.selectedProfileType == .identification ? "Identify" : "Verify" : "Enroll";
		talkButton.setTitle(title, for: .normal)
		
		navigationItem.rightBarButtonItem?.title = SpeakerIdClient.shared.selectedProfile?.name ?? "..."
		
		profileTitleLabel.text = SpeakerIdClient.shared.selectedProfile?.name
		profileIdLabel.text = SpeakerIdClient.shared.selectedProfile?.profileId
		profileStatusLabel.text = SpeakerIdClient.shared.selectedProfile?.enrollmentStatus?.rawValue
		profileCreatedLabel.text = SpeakerIdClient.shared.selectedProfile?.createdDateTimeString(dateFormatter: dateFormatter)
		profileUpdatedLabel.text = SpeakerIdClient.shared.selectedProfile?.lastActionDateTimeString(dateFormatter: dateFormatter)
		profileTimeCountLabel.text = SpeakerIdClient.shared.selectedProfile?.timeCount
		profileRemainingLabel.text = SpeakerIdClient.shared.selectedProfile?.timeCountRemaining
		
		if !allowed { print("Permission request faliled") }
	}
	
	
	func startRecording() {
		
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
			
		} catch let error as NSError {
			print("audioSession error: \(error.localizedDescription)")
			finishRecording(success: false)
		}
	}
	
	
	func finishRecording(success: Bool) {
		
		audioRecorder?.stop()
//		audioRecorder = nil
		
		if success {
			print("Recording succeeded")
		} else {
			print("Recording failed")
		}
	}
	
	
	func playRecording() {
		
		if let recorder = audioRecorder, !recorder.isRecording {
			
			do {
				try audioPlayer = AVAudioPlayer(contentsOf:recorder.url)
				audioPlayer?.delegate = self
				audioPlayer?.prepareToPlay()
				audioPlayer?.play()
				
			} catch let error as NSError {
				print("audioPlayer error: \(error.localizedDescription)")
			}
		}
	}
	
	
	// MARK: - AVAudioRecorderDelegate
	
	func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
		print("Audio Recorder finished recording: successful: \(flag)")
		if !flag {
			finishRecording(success: false)
		} else { //if let profileId = SpeakerIdClient.shared.selected?.profileId {
			if SpeakerIdClient.shared.selectedProfile?.enrollmentStatus == .enrolled {
				switch SpeakerIdClient.shared.selectedProfileType {
				case .identification:
					SpeakerIdClient.shared.identifySpeaker(fileUrl: recorder.url, callback: { (result, profile) in
						DispatchQueue.main.async {
							let alert = UIAlertController(title: profile?.name ?? result?.status?.rawValue ?? "unknown", message: result?.message ?? "", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
							self.present(alert, animated: true, completion: nil)
						}
					})
				case .verification:
					SpeakerIdClient.shared.verifySpeaker(fileUrl: recorder.url, callback: { result in
						DispatchQueue.main.async {
							let alert = UIAlertController(title: result?.result?.rawValue ?? "unknown", message: "confidence: \(result?.confidence?.rawValue ?? "")", preferredStyle: .alert)
							alert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: nil))
							self.present(alert, animated: true, completion: nil)
						}
					})
				}
			} else {
				SpeakerIdClient.shared.createProfileEnrollment(fileUrl: recorder.url) {
					DispatchQueue.main.async {
						self.updateUIforSelectedProfile()
					}
				}
			}
		}
	}
	
	func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
		print("Audio Recorder Encode Error: \(error?.localizedDescription ?? "")")
	}
	
	
	// MARK: - AVAudioPlayerDelegate
	
	func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
		print("Audio Player finished playing: successful: \(flag)")
	}
	
	func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
		print("Audio Player Decode Error: \(error?.localizedDescription ?? "")")
	}
	
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
