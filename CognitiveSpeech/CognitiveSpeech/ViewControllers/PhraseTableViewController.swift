//
//  PhraseTableViewController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/15/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit

class PhraseTableViewController: UITableViewController {
	
	let reuseId = "PhraseTableViewCell"
	
	var phrase: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		phrase = SpeakerIdClient.shared.selectedVerificationProfile?.phrase
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return phrase == nil ? SpeakerIdClient.shared.verificationPhrases.count : 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: reuseId, for: indexPath)
		
		let p = phrase ?? SpeakerIdClient.shared.verificationPhrases[indexPath.row]
		
		cell.textLabel?.text = p
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return phrase == nil ? "Possible Phrases" : "Verificaiton Phrase"
	}
	
	override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
}
