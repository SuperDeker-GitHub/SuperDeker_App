//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit




class PWDViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties

    @IBOutlet weak var psw1EditField: UITextField!
    
    @IBOutlet weak var psw2EditField: UITextField!
    
    @IBOutlet weak var pwdProblemLabelView: UILabel!
    
    @IBOutlet weak var pwdSaveButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let pwd1Text = defaults.string(forKey: "pwd1")
        let pwd2Text = defaults.string(forKey: "pwd2")
        
        psw1EditField.text = pwd1Text
        psw2EditField.text = pwd2Text
        
        psw1EditField?.delegate = self
        
        psw2EditField?.delegate = self
        
         if conformsToPwd(pwd1: pwd1Text ?? "", pwd2: pwd2Text ?? ""){
            pwdSaveButton.isEnabled=true
        }else{
            pwdSaveButton.isEnabled=false
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        let pwd1Text = psw1EditField.text
        let pwd2Text = psw2EditField.text
        let defaults = UserDefaults.standard
        defaults.set(pwd1Text, forKey: "pwd1")
        defaults.set(pwd2Text, forKey: "pwd2")
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        let pwd1Text = psw1EditField.text
        let pwd2Text = psw2EditField.text
        if conformsToPwd(pwd1: pwd1Text ?? "", pwd2: pwd2Text ?? ""){
           pwdSaveButton.isEnabled=true
       }else{
           pwdSaveButton.isEnabled=false
       }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
         
        if textField == psw1EditField {
            let pwd1Text = updatedString
            let pwd2Text = psw2EditField.text
            if conformsToPwd(pwd1: pwd1Text ?? "", pwd2: pwd2Text ?? ""){
               pwdSaveButton.isEnabled=true
           }else{
               pwdSaveButton.isEnabled=false
           }
        }else{
            let pwd1Text = psw1EditField.text
            let pwd2Text = updatedString
            if conformsToPwd(pwd1: pwd1Text ?? "", pwd2: pwd2Text ?? ""){
               pwdSaveButton.isEnabled=true
           }else{
               pwdSaveButton.isEnabled=false
           }
        }
            return true;
        }
    
    func textFieldShouldReturn(_ textField: UITextField)-> Bool{
        // Hide the keyboard
        textField.resignFirstResponder()
        let pwd1Text = psw1EditField.text
        let pwd2Text = psw2EditField.text
        if (textField == self.psw1EditField) {
            textField.resignFirstResponder()
            self.psw2EditField.becomeFirstResponder()
        }
        else{
            if conformsToPwd(pwd1: pwd1Text ?? "", pwd2: pwd2Text ?? ""){
                if textField == psw2EditField {
                    pwdSaveButton.isEnabled=true
                    JumpToRegisterConfirmation()
                }
               pwdSaveButton.isEnabled=true
           }else{
               pwdSaveButton.isEnabled=false
           }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
        
    func conformsToPwd(pwd1: String, pwd2: String)-> Bool{
        //una sola palabra de 4 o más caracteres, hasta 20
        
        if pwd1.count < 6 {
            pwdProblemLabelView.text="passwords must be 6 character or more"
            return false
        }
        if pwd1.count > 30 {
            pwdProblemLabelView.text="passwords must be 30 character or less"
            return false
        }
        if pwd1 != pwd2 {
            pwdProblemLabelView.text="passwords are not equal"
            return false
        }
        pwdProblemLabelView.text=""
        return true
    }
    //MARK Actions
   
    @IBAction func allPwdDone(_ sender: Any) {
        let pwd1Text = psw1EditField.text
        let pwd2Text = psw2EditField.text
        if conformsToPwd(pwd1: pwd1Text ?? "", pwd2: pwd2Text ?? ""){
            JumpToRegisterConfirmation()
        }else{
           pwdSaveButton.isEnabled=false
       }
    }
/*    @IBAction func pwdDone(_ sender: UIBarButtonItem) {
        let pwd1Text = psw1EditField.text
        let pwd2Text = psw2EditField.text
        if conformsToPwd(pwd1: pwd1Text ?? "", pwd2: pwd2Text ?? ""){
            self.JumpToRegisterConfirmation()
        }else{
           pwdSaveButton.isEnabled=false
       }
    }
  */
    func showSpin(vspin: SpinnerViewController){
        addChild(vspin)
        vspin.view.frame = view.frame
        view.addSubview(vspin.view)
        vspin.didMove(toParent: self)
    }
    
    func hideSpin(vspin: SpinnerViewController){
        DispatchQueue.main.async {
            vspin.willMove(toParent: nil)
            vspin.view.removeFromSuperview()
            vspin.removeFromParent()// Check if Error took place
        }
    }
    
    func PopAlert(mess: String){
        DispatchQueue.main.async {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
            
            nextViewController.modalPresentationStyle = .popover
            nextViewController.modalTransitionStyle = .coverVertical
            self.present(nextViewController, animated: true, completion: nil)
            nextViewController.MessageLabel?.text=mess
            
        //self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    
    
    func JumpToRegisterConfirmation(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ConfirmViewController") as! ConfirmViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
