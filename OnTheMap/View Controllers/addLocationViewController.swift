//
//  addLocationViewController.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 6/9/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import UIKit

class addLocationViewController: UIViewController {
    
    // outlets
    
    @IBOutlet weak var locationTextfield: UITextField!
    @IBOutlet weak var websiteTextfield: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationTextfield.delegate = self
        self.websiteTextfield.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // keyboard events =================================================================================================================
    
    // subscribe to keyboard events
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // unsubscribe from keyboard events
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // offset view by the height of the keyboard
    @objc func keyboardWillShow(_ notification: Notification) {
        if view.frame.origin.y == 0 {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    // return the position of the view to normal
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height / 2
    }
    
    // actions =======================================================================================================================
    
    @IBAction func continuePressed(_ sender: Any) {
        guard (locationTextfield.text != ""), (websiteTextfield.text != "")
            else {
            showAlertView(title: AlertTexts.Title, message: AlertTexts.MissingInfo, buttonText: AlertTexts.Ok)
            return
            }
        
        let newPin = self.storyboard?.instantiateViewController(withIdentifier: "submitLocationViewController") as! submitLocationViewController
        newPin.location = locationTextfield.text!
        newPin.website = websiteTextfield.text
        self.navigationController?.pushViewController(newPin, animated: true)
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
     self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    
}
