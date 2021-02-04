//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class AlertViewController: UIViewController {
    //MARK: Properties

    @IBOutlet weak var MessageLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        
        
        // Do any additional setup after loading the view.
    }
    
    //MARK Actions

    @IBAction func OkButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

