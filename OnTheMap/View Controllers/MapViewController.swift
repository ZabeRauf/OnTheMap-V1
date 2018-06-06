//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 5/31/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    // added variables:
    let annotation = MKPointAnnotation()
    
    // outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
 
    // actions
    @IBAction func logoutPressed(_ sender: Any) {
        
        _ = httpInfo.shared.DeleteRequest(UdacityConstants.SessionPath, api: .udacity) { (success) in
            performUIUpdatesOnMain {
                if success {
                    accountInfo.shared.sessionID = nil
                    accountInfo.shared.userId = nil
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    self.showAlertView(title: AlertTexts.Title, message: AlertTexts.LogoutError, buttonText: AlertTexts.Dismiss)
                }
            }
        }
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        getStudentLocations()
    }
    
    // suggested by another student or someone on stackoverflow.
    // placePin places a pin on the map but instead uses a longPressGesture to do the job.
    
    @IBAction func dropPin(_ sender: UILongPressGestureRecognizer) {
        
        let location = sender.location(in: self.mapView)
        
        let locationCoordinates = self.mapView.convert(location, toCoordinateFrom: self.mapView)
        
        showPinDropAlert() { (websiteURL) in
            
            guard let websiteURL = websiteURL else {
                return
            }
            
            let jsonBody = studentLocations.shared.buildJSONBody(mediaURL: websiteURL, latitude: Double(locationCoordinates.latitude), longitude: Double(locationCoordinates.longitude))
            
            self.showActivityIndicator()
            httpInfo.shared.postNewLocation(jsonBody) { (success) in
                
                performUIUpdatesOnMain {
                    
                    if success {
                        self.hideActivityIndicator()
                        self.annotation.coordinate = locationCoordinates
                        self.annotation.title = accountInfo.shared.getFullName()
                        self.annotation.subtitle = websiteURL
                        
                        self.mapView.addAnnotation(self.annotation)
                    } else {
                        self.hideActivityIndicator()
                    }
                    
                }
            }
        }
        
        
    }
    
    // map view stuff
    let pointer = MKPointAnnotation()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self as? MKMapViewDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //getStudentLocations()
        self.navigationController?.navigationBar.isHidden = true
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
    
    func updateAppDelegateList(studentLocations: [studentLocations]) {
        dataSource.sharedInstance.studentData = studentLocations
    }
    
    // loadMap(_ results) loads the results from loading the map in the view controller.
    
    func loadMap(_ results: AnyObject) {
        var annotations = [MKPointAnnotation]()
        let locations = studentLocations.shared.build(results)
        
        updateAppDelegateList(studentLocations: locations)
        
        for studentLocation in locations {
            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(studentLocation.latitude), longitude: CLLocationDegrees(studentLocation.longitude))
            annotation.title = "\(studentLocation.firstName!) \(studentLocation.lastName!)"
            annotation.subtitle = studentLocation.mediaURL
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func getStudentLocations() {
        
        self.showActivityIndicator()
        
        let parameters = [
            ParameterKeys.Limit: ParameterValues.Limit,
            ParameterKeys.Order: ParameterValues.Descending
        ]
        _ = httpInfo.shared.GETRequest(Methods.ParseStudentLocation, parameters: parameters as [String:AnyObject], api: .parse) { (results,error) in
            performUIUpdatesOnMain {
                self.hideActivityIndicator()
                if error == nil {
                    let annotations = self.mapView.annotations
                    self.mapView.removeAnnotations(annotations)
                    self.loadMap(results!)
                } else {
                    self.showAlertView(title: AlertTexts.Title, message: AlertTexts.MapError, buttonText: AlertTexts.CancelPin)
                }
            }
        }
    }
    
    func showPinDropAlert(completionHandler: @escaping (_ website: String?) -> Void) {
        let pinAlertController = UIAlertController(title: "Website", message: "Input your personal website.", preferredStyle: .alert)
        
        pinAlertController.addAction(UIAlertAction(title: AlertTexts.SavePin, style: .default) { (alert) in
            let websiteTextField = pinAlertController.textFields![0] as UITextField
            
            if websiteTextField.text != "" {
                completionHandler(websiteTextField.text)
            } else {
                completionHandler(nil)
            }
        })
        
        pinAlertController.addAction(UIAlertAction(title: AlertTexts.CancelPin, style: .default) { (alert) in
            completionHandler(nil)
        })
        
        pinAlertController.addTextField() { (textField) in
            textField.placeholder = "Website"
            textField.textAlignment = .left
        }
        
        self.present(pinAlertController, animated: true, completion: nil)
        
    }
    
    
}
