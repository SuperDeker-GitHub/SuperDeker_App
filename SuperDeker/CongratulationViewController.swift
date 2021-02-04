//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit
import CoreLocation


class CongratulationViewController: UIViewController, CLLocationManagerDelegate {
    //MARK: Properties

    let locationManager = CLLocationManager()
    
    private var geocoder: CLGeocoder!
    
     override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        locationManager.delegate = self
    }
    
    //MARK Actions
    
    
    @IBAction func geolocation(_ sender: UIButton) {
        // 1
            let status = CLLocationManager.authorizationStatus()

            switch status {
                // 1
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                geocoder = CLGeocoder()
                locationManager.startUpdatingLocation()
                return

                // 2
            case .denied, .restricted:
                let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings for the SuperDeker app", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okAction)

                present(alert, animated: true, completion: nil)
                return
            case .authorizedAlways, .authorizedWhenInUse:
                geocoder = CLGeocoder()
                locationManager.startUpdatingLocation()
                break

            @unknown default:
                fatalError()
                
            }

    }
    
    
    func JumpToDOB(){
        DispatchQueue.main.async {
            
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DobViewController") as! DobViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    //MARK location delegate funcionts
    
    // 1
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
        if let currentLocation = locations.last {
            geocoder?.reverseGeocodeLocation(currentLocation) { (placemarks, error) in
                // 1
                if let error = error {
                    print(error)
                }
                        
                // 2
                guard let placemark = placemarks?.first else { return }
                 print(placemark)
                // Geary & Powell, Geary & Powell, 299 Geary St, San Francisco, CA 94102, United States @ <+37.78735352,-122.40822700> +/- 100.00m, region CLCircularRegion (identifier:'<+37.78735636,-122.40822737> radius 70.65', center:<+37.78735636,-122.40822737>, radius:70.65m)
                        
                // 3
                // 4
                //DispatchQueue.main.async {
                    
                    guard let country = placemark.country else { return }
                    guard let state = placemark.locality else { return }
                    guard let city = placemark.administrativeArea else { return }
                    let zipCode = placemark.postalCode ?? ""
                    
                    let defaults = UserDefaults.standard
                    
                    defaults.setValue(country, forKey: "country")
                    defaults.setValue(city, forKey: "state")
                    defaults.setValue(state, forKey: "city")
                    defaults.setValue(zipCode, forKey: "zipCode")
                    
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ProfileLocationViewController") as! ProfileLocationViewController
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                    self.locationManager.stopUpdatingLocation()
                    
                //}
            }
            
            
            //print("Current location: \(currentLocation)")
        }
    }

    // 2
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
}
