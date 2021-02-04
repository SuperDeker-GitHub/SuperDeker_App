//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class WelcomeViewController: UIViewController {
    //MARK: Properties

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
         navigationController?.navigationBar.shadowImage = UIImage()
         navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
    
    }

    //MARK: Actions
 
    @IBAction func dismiisme(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    


    
   
}


