//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class ProfileLocationEditableViewController: UIViewController {
    //MARK: Properties
     
    @IBOutlet weak var CountryButton: UIButton!
    
    @IBOutlet weak var StateButton: UIButton!
    
    @IBOutlet weak var CityButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
           //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            //navigationController?.navigationBar.shadowImage = UIImage()
            //navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        
    }
    //MARK Actions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        let country = defaults.string(forKey: "country")
        if country == nil || country == "" {
            CountryButton.setTitle("Click to select country >", for: .normal)
        }
        else{
            CountryButton.setTitle(country, for: .normal)
            let state = defaults.string(forKey: "state")
            if state == nil || state == "" {
                StateButton.setTitle("Click to select state >", for: .normal)
                defaults.set("", forKey: "city")
            }
            else{
                StateButton.setTitle(state, for: .normal)
                let city = defaults.string(forKey: "city")
                if city == nil || city == "" {
                    CityButton.setTitle("Click to select city >", for: .normal)
                }
                else{
                    CityButton.setTitle(city, for: .normal)
                
                }
            }

        }
    }
     
    
    func JumpToVerifyEmail(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyEmailViewController") as! VerifyEmailViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
 
    
}
