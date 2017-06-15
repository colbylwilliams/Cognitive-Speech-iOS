//
//  StartViewController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit
import AVFoundation

class StartViewController: UIViewController, AVAudioRecorderDelegate {
	
	@IBOutlet weak var profileTitleLabel: UILabel!
	@IBOutlet weak var profileIdLabel: UILabel!
	@IBOutlet weak var profileStatusLabel: UILabel!
	@IBOutlet weak var profileCreatedLabel: UILabel!
	@IBOutlet weak var profileUpdatedLabel: UILabel!
	@IBOutlet weak var profileRemainingLabel: UILabel!
	@IBOutlet weak var profileTimeCountLabel: UILabel!
	
	@IBOutlet var profileLabels: [UILabel]!
	
	@IBOutlet weak var talkButton: UIButton!
	@IBOutlet weak var shortAudioButton: UIBarButtonItem!
	
	@IBOutlet weak var speakerTypeSegmentedControl: UISegmentedControl!
	
	private	var _dateFormatter: DateFormatter?
	var dateFormatter: DateFormatter? {
		if _dateFormatter == nil {
			_dateFormatter = DateFormatter()
			_dateFormatter?.dateStyle = .short
			_dateFormatter?.timeStyle = .short
		}
		return _dateFormatter!
	}
	
	var recordingSession: AVAudioSession?
	
	
	override func viewDidLoad() {
		
        super.viewDidLoad()
		
		talkButton.layer.cornerRadius = 5
		
		talkButton.isEnabled = false
		talkButton.backgroundColor = UIColor.lightGray
		
		shortAudioButton.title = SpeakerIdClient.shared.shortAudio ? "Short" : "Long"
		
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
	
	
	@IBAction func shortAudioButtonTouched(_ sender: Any) {
		SpeakerIdClient.shared.shortAudio = !SpeakerIdClient.shared.shortAudio
		shortAudioButton.title = SpeakerIdClient.shared.shortAudio ? "Short" : "Long"
	}
	
	@IBAction func speakerTypeSegmentedControlChanged(_ sender: Any) {
		SpeakerIdClient.shared.setSelectedProfileType(typeInt: speakerTypeSegmentedControl.selectedSegmentIndex) {
			DispatchQueue.main.async {
				self.updateUIforSelectedProfile()
			}
		}
	}
	
	@IBAction func unwind(segue:UIStoryboardSegue) { }
	
	
	func updateUIforSelectedProfile(recordingAllowed: Bool? = nil) {
		
		let allowed = recordingAllowed ?? (recordingSession != nil && recordingSession!.recordPermission() == .granted)
		
		talkButton.isEnabled = allowed
		talkButton.backgroundColor = allowed ? talkButton.tintColor : UIColor.lightGray
		
		let title = SpeakerIdClient.shared.selectedProfile?.enrollmentStatus == .enrolled ? SpeakerIdClient.shared.selectedProfileType == .identification ? "Identify" : "Verify" : "Enroll";
		talkButton.setTitle(title, for: .normal)
		
		navigationItem.rightBarButtonItem?.title = SpeakerIdClient.shared.selectedProfile?.name ?? "..."
		
		for label in profileLabels {
			label.isHidden = SpeakerIdClient.shared.selectedProfile == nil
		}
		
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
