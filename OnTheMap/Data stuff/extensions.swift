//
//  extensions.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 5/23/18.
//  Copyright © 2018 Zaben. All rights reserved.
//
// Extends all UIViewController type files. Since the alert views have a use in those file types. 
//

import Foundation
import UIKit

extension UIViewController {
    
    // function that is responsible for displaying alert notifications. 
    
    func showAlertView(title: String, message: String, buttonText: String) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let action = UIAlertAction(title: buttonText, style: .destructive, handler: nil)
        alertController.addAction(action)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
