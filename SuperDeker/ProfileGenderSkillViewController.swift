//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class ProfileGenderSkillViewController: UIViewController, UIPickerViewDelegate , UIPickerViewDataSource {
    
    var pickerData:[String] = [String]()
    
    @IBOutlet weak var genderSwitch: UISwitch!
    
    @IBOutlet weak var stickHandSwitch: UISwitch!
    
    @IBOutlet weak var playerLevelPickerView: UIPickerView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let genderBool = defaults.bool(forKey: "Gender")
        let stickHandBool = defaults.bool(forKey: "StickHand")
        
        let pickerSelection = defaults.integer(forKey: "LevelSelection")
        genderSwitch.isOn=genderBool
        stickHandSwitch.isOn=stickHandBool
        genderSwitch.tintColor = genderSwitch.onTintColor
        genderSwitch.backgroundColor = genderSwitch.onTintColor
        genderSwitch.layer.cornerRadius = 16
        stickHandSwitch.tintColor = stickHandSwitch.onTintColor
        stickHandSwitch.backgroundColor = stickHandSwitch.onTintColor
        stickHandSwitch.layer.cornerRadius = 16
        playerLevelPickerView.delegate = self
        playerLevelPickerView.dataSource = self
        pickerData = ["AAA","AA","A","B","C","D"]
        playerLevelPickerView.selectRow(pickerSelection, inComponent: 0, animated: true)
        defaults.set(pickerData[pickerSelection], forKey: "PlayerLevel") // in case the user enters the view controller and does not change the picker
    }
    override func viewDidDisappear(_ animated: Bool) {
        //let nick = "gender"
        let defaults = UserDefaults.standard
        //defaults.set(nick, forKey: "NickName")
        defaults.set(genderSwitch.isOn, forKey: "Gender")
        defaults.set(stickHandSwitch.isOn, forKey: "StickHand")
    }
    
    //MARK: UIPickerViewDelegate
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView:UIPickerView,titleForRow row:Int, forComponent component:Int) -> String?{
        return pickerData[row]
    }
    
    func pickerView(_ pickerView:UIPickerView,didSelectRow row:Int, inComponent component:Int){
        let defaults = UserDefaults.standard
        defaults.set(row, forKey: "LevelSelection")
        defaults.set(pickerData[row], forKey: "PlayerLevel")
    }
    //MARK Actions
    
    @IBAction func ProfileGenderDone(_ sender: Any) {
    }
    
    
    func JumpToDOB(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DobViewController") as! DobViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
