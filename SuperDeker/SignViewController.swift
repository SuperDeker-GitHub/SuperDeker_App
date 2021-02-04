//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class SignViewController: UIViewController {
    //MARK: Properties

    @IBOutlet weak var SignUINavigation: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        
        
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        //defaults.set(false, forKey: "FirstRun")
        
        let FirstRun = defaults.bool(forKey: "FirstRun")
       
        if (FirstRun == false){
            ExecWelcome()
            //defaults.set(true, forKey: "FirstRun")
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    
    }

        func ExecWelcome(){
            DispatchQueue.main.async {
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                self.navigationController?.pushViewController(nextViewController, animated: true)
            
            }
        
    }
}

