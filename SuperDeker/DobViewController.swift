//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class DobViewController: UIViewController {
    //MARK: Properties

    @IBOutlet weak var DobNavigationBar: UINavigationItem!
    
    @IBOutlet weak var DatePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        
        DatePicker.maximumDate = Date()
        
        let defaults = UserDefaults.standard
        var oldDate = Date()
        if (defaults.object(forKey: "DOB") != nil){
            oldDate = defaults.object(forKey: "DOB")as! Date
        }
        
        DatePicker.date=oldDate
        
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(DatePicker.date, forKey: "DOB")
    }

}

