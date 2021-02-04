//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit


struct VerifyEmailModel: Codable {
    let email: String
    let verified: Bool
}

class VerifyEmailViewController: UIViewController {
    //MARK: Properties

     
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
    
    
    @IBAction func CheckConfirmedEmail(_ sender: UIButton) {
        let spin = SpinnerViewController()
        // add the spinner view controller
        showSpin(vspin:spin)
        // checking on https://dossierplus-srv.com/superdeker/api/ConfirmEmail.php/Email
        
        let defaults = UserDefaults.standard
        
        let emailText = defaults.string(forKey: "email") ?? ""
        
        // Create URL
        let url = URL(string: "https://dossierplus-srv.com/superdeker/api/ConfirmEmail.php/" + emailText)
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
                let confirmedNew = self.parseVerifyEmailModel(data: data)
                let verified = confirmedNew?.verified
                if !(verified ?? false){
                    self.PopAlert(mess: "You have not verified your email, please go to your email inbox, select the email we sent you and click on the url link")
                }
                else{
                    //let defaults = UserDefaults.standard
                    //clean defaults
                    self.JumpToProfile1()
                }
                
                //print("Response data string:\n \(dataString)")
            }
            
        }
        task.resume()
        /*
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DobViewController") as! DobViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    */
    }
    
    
   
    
    func parseVerifyEmailModel(data: Data) -> VerifyEmailModel? {
        
        var returnValue: VerifyEmailModel?
        do {
            returnValue = try JSONDecoder().decode(VerifyEmailModel.self, from: data)
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
    
    
    func JumpToProfile1(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Profile1NavigationController") as! UINavigationController
            
            UIApplication.shared.windows.first?.rootViewController = nextViewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            
            //self.navigationController?.pushViewController(nextViewController, animated: true)
            
            //Clean userdefaults
            
            let defaults = UserDefaults.standard
            
            let nickText = defaults.string(forKey: "NickName")
            let emailText = defaults.string(forKey: "email")
            let pwd = defaults.string(forKey: "pwd1")
            
            
            defaults.set(emailText, forKey: "VerifiedEmail")
            defaults.set(nickText, forKey: "Nick")
            defaults.set(pwd, forKey: "password")
            defaults.set("", forKey: "email")
            defaults.set("", forKey: "NickName")
            defaults.set("", forKey: "pwd1")
            defaults.set("", forKey: "pwd2")
            defaults.set(nil, forKey: "DOB")
            
        }
    }
}
