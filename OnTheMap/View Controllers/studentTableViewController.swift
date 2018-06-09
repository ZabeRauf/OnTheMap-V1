//
//  studentTableViewController.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 6/8/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import UIKit

class studentTableViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        _ = httpInfo.shared.DeleteRequest(UdacityConstants.SessionPath, api: .udacity) { (success) in
            performUIUpdatesOnMain {
                if success {
                    accountInfo.shared.sessionID = nil
                    accountInfo.shared.userId = nil
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showAlertView(title: AlertTexts.Title, message: AlertTexts.LogoutError, buttonText: AlertTexts.Dismiss)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

// table view data extension

extension studentTableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.sharedInstance.studentData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell") as! studentTableViewCell
        cell.imageView?.image = UIImage(named: "userPin")
        cell.textLabel?.text = dataSource.sharedInstance.studentData[indexPath.row].getName()
        cell.detailTextLabel?.text = dataSource.sharedInstance.studentData[indexPath.row].mediaURL
        return cell
    }
}

// table view delegate stuff

extension studentTableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let app = UIApplication.shared
        if let toOpen = dataSource.sharedInstance.studentData[indexPath.row].mediaURL {
            guard let url = URL(string: toOpen) else {
                showAlertView(title: AlertTexts.Title, message: AlertTexts.InvalidURL, buttonText: AlertTexts.Dismiss)
                return
            }
            app.open(url)
        }
    }
}

