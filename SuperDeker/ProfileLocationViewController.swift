//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class ProfileLocationViewController: UIViewController {
    //MARK: Properties
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var stateLabel: UILabel!
        
    @IBOutlet weak var cityLabel: UILabel!
    
    @IBOutlet weak var zipCodeTitleLabel: UILabel!
    @IBOutlet weak var zipCodeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
//        countryEditText.text = defaults.string(forKey: "country")
        countryLabel.text = defaults.string(forKey: "country")
        
//        stateEditText.text = defaults.string(forKey: "city")
        stateLabel.text = defaults.string(forKey: "state")
//        cityTextField.text = defaults.string(forKey: "state")
        cityLabel.text = defaults.string(forKey: "city")
        
        zipCodeLabel.text = defaults.string(forKey: "zipCode")
        
        zipCodeTitleLabel.isHidden = (defaults.string(forKey: "zipCode") == "")
        zipCodeLabel.isHidden = (defaults.string(forKey: "zipCode") == "")
        
    }
    
    //MARK Actions
    
    
    func JumpToVerifyEmail(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyEmailViewController") as! VerifyEmailViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
