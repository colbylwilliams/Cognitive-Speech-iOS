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
	@IBOutlet weak var shortAudioSwitch: UISwitch!
	@IBOutlet weak var shortAudioSwitchBarItem: UIBarButtonItem!
	
	@IBOutlet weak var phraseContainerView: UIView!
	
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
		
		phraseContainerView.isHidden = true
		
		talkButton.isEnabled = false
		talkButton.layer.cornerRadius = 5
		talkButton.backgroundColor = UIColor.lightGray
		
		shortAudioSwitch.isOn = SpeakerIdClient.shared.shortAudio
		
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
	
	
	@IBAction func shortAudioSwitchChanged(_ sender: UISwitch) {
		SpeakerIdClient.shared.shortAudio = sender.isOn
		setTalkButtonTitle()
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
		talkButton.backgroundColor = allowed ? navigationController?.navigationBar.barTintColor : UIColor.lightGray
		
		setTalkButtonTitle()
		
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
		
		switch SpeakerIdClient.shared.selectedProfileType {
		case .identification:
			phraseContainerView.isHidden = true
			navigationItem.leftBarButtonItem?.isEnabled = true
		case .verification:
			phraseContainerView.isHidden = false
			navigationItem.leftBarButtonItem?.isEnabled = false
			if let phraseController = childViewControllers.first as? PhraseTableViewController {
				phraseController.phrase = SpeakerIdClient.shared.selectedVerificationProfile?.phrase
				phraseController.tableView.reloadData()
			}
		}
		
		print("Recording Permission = \(allowed)")
	}
	
	func setTalkButtonTitle() {
		var title = SpeakerIdClient.shared.selectedProfile?.enrollmentStatus == .enrolled ? SpeakerIdClient.shared.selectedProfileType == .identification ? "Identify" : "Verify" : "Enroll";
		if SpeakerIdClient.shared.selectedProfileType == .identification && SpeakerIdClient.shared.shortAudio {
			title += " (short)"
		}
		talkButton.setTitle(title, for: .normal)
	}
	
	func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let documentsDirectory = paths[0]
		return documentsDirectory
	}
}
