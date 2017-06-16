//
//  ProfileTableViewController.swift
//  CognitiveSpeech
//
//  Created by Colby Williams on 6/12/17.
//  Copyright © 2017 Colby Williams. All rights reserved.
//

import CoreGraphics
import UIKit

class ProfileTableViewController: UITableViewController {
	
	@IBOutlet var emptyView: UIView!
	
	private	var _dateFormatter: DateFormatter?
	var dateFormatter: DateFormatter? {
		if _dateFormatter == nil {
			_dateFormatter = DateFormatter()
			_dateFormatter?.dateStyle = .short
			_dateFormatter?.timeStyle = .short
		}
		return _dateFormatter!
	}
	
	var selectedIndexPath: IndexPath?
	
	
	override func viewDidLoad() {
        super.viewDidLoad()
		
		title = "\(SpeakerIdClient.shared.selectedProfileType.string) Profiles"
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		selectIndexPath(tableView, indexPath: nil)
	}
	
	@IBAction func refreshValueChanged(_ sender: UIRefreshControl) {
		if sender.isRefreshing {
			SpeakerIdClient.shared.refreshAllProfiles {
				DispatchQueue.main.async {
					sender.endRefreshing()
					self.tableView.reloadData()
				}
			}
		}
	}
	
	@IBAction func addButtonTouched(_ sender: Any) {
		let alert = UIAlertController(title: "Create Profile", message: "Enter the profile owner's name", preferredStyle: .alert)
		
		alert.addTextField { textField in
			textField.placeholder = "Name"
			textField.returnKeyType = .done
			textField.autocapitalizationType = .words
		}
		
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		
		alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { action in
			if let text = alert.textFields?.first?.text {
				SpeakerIdClient.shared.createProfile(profileName: text) {
					DispatchQueue.main.async {
						self.tableView.reloadData()
						self.selectIndexPath(self.tableView, indexPath: nil)
					}
				}
			}
		}))
		
		present(alert, animated: true, completion: nil)
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
		
		cell.textLabel?.text = profile.name
		cell.detailTextLabel?.text = profile.enrollmentStatus?.rawValue// "Status: \(profile.enrollmentStatus?.rawValue ?? "") | created:\(profile.createdDateTimeString(dateFormatter: dateFormatter))"
		cell.detailTextLabel?.textColor = profile.enrollmentStatus?.color ?? UIColor.darkText
		
//		cell.isSelected = selectedIndexPath == indexPath
		cell.accessoryType = selectedIndexPath == indexPath ? .checkmark : .none
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction.init(style: .normal, title: "Reset") { (action, view, callback) in
			self.resetCell(tableView, indexPath: indexPath)
			callback(false)
		}
		action.backgroundColor = UIColor.orange
		
		return UISwipeActionsConfiguration(actions: [ action ] );
	}
	
	func resetCell(_ tableView: UITableView, indexPath: IndexPath) {
		if let profileId = SpeakerIdClient.shared.profiles[indexPath.row].profileId {
			SpeakerIdClient.shared.resetProfileEnrollment(profileId: profileId) {
				DispatchQueue.main.async {
					tableView.reloadRows(at: [indexPath], with: .automatic)
				}
			}
		}
	}
	
	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		let action = UIContextualAction.init(style: .destructive, title: "Delete") { (action, view, callback) in
			if let profileId = SpeakerIdClient.shared.profiles[indexPath.row].profileId {
				SpeakerIdClient.shared.deleteProfile(profileId: profileId) {
					DispatchQueue.main.async {
						tableView.deleteRows(at: [indexPath], with: .fade)
						if indexPath == self.selectedIndexPath {
							self.selectedIndexPath = nil
						}
						self.selectIndexPath(tableView, indexPath: nil)
						callback(true)
					}
				}
			}
		}
		return UISwipeActionsConfiguration(actions: [ action ] );
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		selectIndexPath(tableView, indexPath: indexPath)
		dismiss(animated: true, completion: nil)
	}
	
	
	func selectIndexPath(_ tableView: UITableView, indexPath index: IndexPath?) {
		var indexPath = index
		
		if indexPath == nil {
			if let i = SpeakerIdClient.shared.selectedProfileIndex() {
				indexPath = IndexPath(row: i, section: 0)
			}
		} else {
			SpeakerIdClient.shared.selectProfile(byIndex: indexPath!.row)
		}
		
		var indexPaths: [IndexPath] = []
		
		if let indexPath = indexPath {
			indexPaths.append(indexPath)
		}
		
		if let oldIndexPath = selectedIndexPath {
			indexPaths.append(oldIndexPath)
		}
		
		selectedIndexPath = indexPath
		
		if !indexPaths.isEmpty {
			tableView.reloadRows(at: indexPaths, with: .automatic)
		}
		
		if let navigationControllerView = navigationController?.view {
			if SpeakerIdClient.shared.profiles.isEmpty {
				if !emptyView.isDescendant(of: navigationControllerView) {
					emptyView.frame = CGRect(x: 0, y: view.frame.minY + 0.5, width: view.frame.width, height: view.frame.height - 0.5)
					navigationControllerView.addSubview(emptyView)
				}
			} else if emptyView.isDescendant(of: navigationControllerView) {
				emptyView.removeFromSuperview()
			}
		}
	}
}
