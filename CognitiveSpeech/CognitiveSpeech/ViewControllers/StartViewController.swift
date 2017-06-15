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
//	var audioRecorder: AVAudioRecorder?
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
	
	@IBAction func playButtonTouched(_ sender: Any) {
//		playRecording()
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
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		print("StartViewController viewWillAppear")
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		print("StartViewController viewDidAppear")
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
		
		print("Recording Permission = \(allowed)")
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
