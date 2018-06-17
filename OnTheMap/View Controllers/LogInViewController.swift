//
//  LogInViewController.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 5/21/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {
    
    // outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var newAccountButton: UIButton!
    
    // actions
    @IBAction func loginButton(_ sender: Any) {
        login()
    }
    
    @IBAction func openUdacity(sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated")!)
    }
    
    // view controller
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailTextField.delegate = self as UITextFieldDelegate
        self.passwordTextField.delegate = self as UITextFieldDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotificaiton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotification()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // subscribes to keyboard events.
    
    func subscribeToKeyboardNotificaiton(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    // unsubscribe from keyboard events
    
    func unsubscribeFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    // moves view so keyboard doesn't cover bottom textField.
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if view.frame.origin.y == 0 {
            view.frame.origin.y = getKeyboardHeight(notification) * (-1)
        }
    }
    
    // returns to normal view.
    
    @objc func keyboardWillHide(_ notification: Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height / 2
    }
    
    func showActivityIndicator() {
        self.activityIndicator.center = self.view.center
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        view.addSubview(self.activityIndicator)
        
        self.activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func hideActivityIndicator() {
        self.activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    // login() checks if the email or password fields are empty. If it can get the user login data, it'll also try to get the users public data.
    // It has error checkers, and if there are no errors, it'll continue running.
   
    func login() {
        self.showActivityIndicator()
        
        guard (emailTextField.text != ""), (passwordTextField.text != "")
            else {
                self.hideActivityIndicator()
                showAlertView(title: AlertTexts.Title, message: AlertTexts.MissingCredentials, buttonText: AlertTexts.Ok)
                return
            }
        
        let jsonBody = httpInfo.shared.buildAuthenticationHttpBody(username: emailTextField.text!, password: passwordTextField.text!)
        
        _ = httpInfo.shared.POSTRequest(UdacityConstants.SessionPath, parameters: nil, api: API.udacity, jsonBody: jsonBody) { (results,error) in
        
            if error != nil {
                performUIUpdatesOnMain {
                    if error!.localizedDescription == ResponseCodes.BadCredentials {
                        self.hideActivityIndicator()
                        self.showAlertView(title:AlertTexts.Title, message: AlertTexts.Request403, buttonText: AlertTexts.TryAgain)
                    }
                    else if error!.code == NSURLErrorTimedOut {
                        self.hideActivityIndicator()
                        self.showAlertView(title: AlertTexts.Title, message: AlertTexts.RequestTimedOut, buttonText: AlertTexts.Ok)
                    }
                    else {
                        self.hideActivityIndicator()
                        self.showAlertView(title: AlertTexts.Title, message: AlertTexts.MapError, buttonText: AlertTexts.Dismiss)
                    }
                }
            }
            else {
                if self.getLoginData(results!) {
                    self.getPublicData(accountInfo.shared.userId!) { (firstName, lastName) in
                        performUIUpdatesOnMain {
                            guard (firstName != nil)
                                else {
                                    self.hideActivityIndicator()
                                    self.showAlertView(title: AlertTexts.Title, message: AlertTexts.Request403, buttonText: AlertTexts.TryAgain)
                                    return
                            }
                            self.hideActivityIndicator()
                            accountInfo.shared.firstName = firstName
                            accountInfo.shared.lastName = lastName
                            self.performSegue(withIdentifier: "logMeIn", sender: nil)
                        }
                    }
                }
                else {
                    performUIUpdatesOnMain {
                        self.hideActivityIndicator()
                        // alert view for login error.
                        self.showAlertView(title: AlertTexts.Title, message: AlertTexts.LoginError, buttonText: AlertTexts.TryAgain)
                    }
                }
            }
        }
    }

    
    
    // getLoginData makes sure it has log in data and stores the info before continuing.
    
    func getLoginData(_ results: AnyObject) -> Bool {
        let success = true
        guard let account = results[JSONResponseKeys.Account] as? [String:AnyObject] else {
            return !success
        }
        
        guard let session = results[JSONResponseKeys.Session] as? [String:AnyObject] else {
            return !success
        }
        
        guard let accountId = account[JSONResponseKeys.AccountKey] as? String else {
            return !success
        }
        
        guard let sessionId = session[JSONResponseKeys.SessionId] as? String else {
            return !success
        }
        
        accountInfo.shared.sessionID = sessionId
        accountInfo.shared.userId = accountId
        return success
    }
    
    // getPublicData uses the account ID of a udacity user and gets the first and last name of the user.
    
    func getPublicData(_ accountId: String, completionHandler: @escaping (_ firstName: String?,_ lastName: String?) -> Void) {
        let method = Methods.UdacityUser.replacingOccurrences(of: "<user_id>", with: accountId)
        
        _ = httpInfo.shared.GETRequest(method, parameters: nil, api: .udacity) { (results,error) in
            guard let user = results?[JSONResponseKeys.User] as? [String:AnyObject] else {
                completionHandler(nil, nil)
                return
            }
            guard let firstName = user[JSONResponseKeys.FirstName] as? String else {
                completionHandler(nil, nil)
                return
            }
            
            guard let lastName = user[JSONResponseKeys.LastName] as? String else {
                completionHandler(nil, nil)
                return
            }
            completionHandler(firstName, lastName)
        }
    }
}
