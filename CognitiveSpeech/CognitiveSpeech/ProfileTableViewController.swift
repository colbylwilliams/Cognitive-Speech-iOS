//
//  ProfileTableViewController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

	@IBOutlet var addButton: UIBarButtonItem!
	
	override func viewDidLoad() {
        super.viewDidLoad()
    }

	@IBAction func refreshValueChanged(_ sender: UIRefreshControl) {
		if sender.isRefreshing {
			SpeakerIdClient.shared.refreshAllIdentificationProfiles {
				DispatchQueue.main.async {
					sender.endRefreshing()
					self.tableView.reloadData()
				}
			}
		}
	}
	
	@IBAction func addButtonTouched(_ sender: Any) {
		SpeakerIdClient.shared.createIdentificationProfile {
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		navigationItem.leftBarButtonItem?.isEnabled = !editing
	}
	
	// MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SpeakerIdClient.shared.profiles.count
    }

	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTableViewCell", for: indexPath)

		let profile = SpeakerIdClient.shared.profiles[indexPath.row]
		
		cell.textLabel?.text = profile.identificationProfileId		
		cell.detailTextLabel?.text = "Status: \(profile.enrollmentStatus?.rawValue ?? "") | created:\(profile.createdDateTimeString)"
		
        return cell
    }
	
	
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
	
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
			if let profileId = SpeakerIdClient.shared.profiles[indexPath.row].identificationProfileId {
				SpeakerIdClient.shared.deleteIdentificationProfile(profileId: profileId) {
					DispatchQueue.main.async {
						tableView.deleteRows(at: [indexPath], with: .fade)
					}
				}
			}
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
	
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		SpeakerIdClient.shared.speakerProfiles.setSelected(index: indexPath.row)
	}

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
