//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit


struct EmailModel: Codable {
    let email: String
    let used: Bool
}

class EmailViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties

    @IBOutlet weak var emailSaveButton: UIBarButtonItem!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var problemEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let emailText = defaults.string(forKey: "email")
        emailTextField.text = emailText
        emailTextField?.delegate = self;
        if conformsToEmail(email: emailText ?? ""){
            emailSaveButton.isEnabled=true
        }else{
            emailSaveButton.isEnabled=false
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        let email = emailTextField.text
        let defaults = UserDefaults.standard
        defaults.set(email, forKey: "email")
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        let text = textField.text ?? ""
        
        if conformsToEmail(email: text){
            emailSaveButton.isEnabled=true
        }else{
            emailSaveButton.isEnabled=false
        }
       
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
         if conformsToEmail(email: updatedString ?? ""){
                emailSaveButton.isEnabled=true
        }else{
                emailSaveButton.isEnabled=false
            }
            return true;
        }
    
    func textFieldShouldReturn(_ textField: UITextField)-> Bool{
        // Hide the keyboard
        textField.resignFirstResponder()
        let text = textField.text ?? ""
        
        if conformsToEmail(email: text){
            emailDone(emailSaveButton)
        }else{
            emailSaveButton.isEnabled=false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
        
    func conformsToEmail(email: String)-> Bool{
        //una sola palabra de 4 o más caracteres, hasta 20
        
        if !email.isEmail {
            problemEmail.text="email format not valid"
            return false
        }
        problemEmail.text=""
        return true
    }
    //MARK Actions
   
    @IBAction func emailDone(_ sender: UIBarButtonItem) {
        let spin = SpinnerViewController()
        // add the spinner view controller
        showSpin(vspin:spin)
        // checking on https://dossierplus-srv.com/superdeker/api/CheckEmailUsed.php/Email
        
        let email = emailTextField.text ?? ""
        
        // Create URL
        let url = URL(string: "https://dossierplus-srv.com/superdeker/api/CheckEmailUsed.php/"+email)
        guard let requestUrl = url else { fatalError() }
        // Create URL Request
        var request = URLRequest(url: requestUrl)
        // Specify HTTP Method to use
        request.httpMethod = "GET"
        // Send HTTP Request
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            self.hideSpin(vspin: spin)
            
            if let error = error {
                print("Error took place \(error)")
                return
            }
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let emailNew=self.parseEmailModel(data: data)
                let used = emailNew?.used
                if (used ?? false){
                    self.PopAlert(mess: "This email is registered, verify if this is your email")
                }
                else{
                    let defaults = UserDefaults.standard
                    defaults.set(email, forKey: "email")
                    self.JumpToPWD()
                }
                print("email:"+emailNew!.email )
                print("used:" + (emailNew!.used ? "true":"false"))
            }
            
        }
        task.resume()
    }
    
    
    
    func parseEmailModel(data: Data) -> EmailModel? {
        var returnValue: EmailModel?
        do {
            returnValue = try JSONDecoder().decode(EmailModel.self, from: data)
        } catch {
            print("Error took place\(error.localizedDescription).")
        }
        
        return returnValue
    }
    
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
    
    
    func JumpToPWD(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "PWDViewController") as! PWDViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
