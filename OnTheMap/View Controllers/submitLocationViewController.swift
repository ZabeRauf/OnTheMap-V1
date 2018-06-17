//
//  submitLocationViewController.swift
//  OnTheMap
//
//  Created by Zabe Rauf on 6/10/18.
//  Copyright © 2018 Zaben. All rights reserved.
//

import UIKit
import MapKit

class submitLocationViewController: UIViewController {

    // outlets
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    
    // variables
    var location: String!
    var website: String!
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        self.submitButton.isHidden = false
        let geoCodes = CLGeocoder()
        showActivityIndicator()
        
        // error when adding a location
        geoCodes.geocodeAddressString(location) {
            (placemarks, error) -> Void in
            
            self.hideActivityIndicator()
            if error == nil {
                if placemarks!.count != 0 {
                    self.annotation.coordinate = (placemarks?[0].location?.coordinate)!
                    self.annotation.title = accountInfo.shared.getFullName()
                    self.annotation.subtitle = self.website
                    self.mapView.addAnnotation(self.annotation)
                    
                    let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    let region = MKCoordinateRegion(center: self.annotation.coordinate, span: span)
                    self.mapView.setRegion(region, animated: true)
                }
            }
            else {
                self.submitButton.isHidden = true
                self.showAlertView(title: AlertTexts.Title, message: AlertTexts.LocationError, buttonText: AlertTexts.Dismiss)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // actions
    
    @IBAction func submitPressed(_ sender: Any) {
        let jsonBody = studentLocations.shared.buildJSONBody(mediaURL: self.annotation.subtitle!, latitude: Double(self.annotation.coordinate.latitude), longitude: Double(self.annotation.coordinate.longitude))
        
        self.showActivityIndicator()
        httpInfo.shared.postNewLocation(jsonBody) { (success) in
            performUIUpdatesOnMain {
                if success {
                    self.hideActivityIndicator()
                    self.navigationController?.popToRootViewController(animated: true)
                    self.mapView.addAnnotation(self.annotation)
                }
                else {
                    self.hideActivityIndicator()
                    self.showAlertView(title: AlertTexts.Title, message: AlertTexts.PostError, buttonText: AlertTexts.Dismiss)
                }
            }
        }
    }
}

extension submitLocationViewController: MKMapViewDelegate {
    
}


