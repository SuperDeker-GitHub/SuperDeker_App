//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

struct RegisterModel: Codable {
    var nickname: String
    var email: String
    var pwd: String
    var dob: String
}

struct RegRetValue: Codable {
    var id: Int64
    var err: String
}

class ConfirmViewController: UIViewController {
    //MARK: Properties
    
    @IBOutlet weak var nicknameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var dobLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let nickText = defaults.string(forKey: "NickName")
        nicknameLabel.text = nickText
        let emailText = defaults.string(forKey: "email")
        emailLabel.text = emailText
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let DateDOB = defaults.object(forKey: "DOB") as! Date
        let dobText =  formatter.string(from: DateDOB)
        //let dobText = defaults.string(forKey: "DOB")
        dobLabel.text = dobText
    }
    
    //MARK Actions
    
    @IBAction func DoSignUp(_ sender: UIBarButtonItem) {
        let spin = SpinnerViewController()
        // add the spinner view controller
        showSpin(vspin:spin)
        // register on https://dossierplus-srv.com/superdeker/api/DoRegistration.php/NickName/Email/Pwd/DOB
        let defaults = UserDefaults.standard
        let nickText = defaults.string(forKey: "NickName")
        let emailText = defaults.string(forKey: "email")
        let pwdText = defaults.string(forKey: "pwd1")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let DateDOB = defaults.object(forKey: "DOB") as! Date
        let dobText =  formatter.string(from: DateDOB)
         
        var urlString = "https://dossierplus-srv.com/superdeker/api/DoRegistration.php/" + (nickText ?? "")
        urlString += "/" + (emailText ?? "")
        urlString += "/" + (pwdText ?? "")
        urlString += "/" + (dobText)
    
        print(urlString)
        
        let url = URL(string: urlString )
                        
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
                let RegModelRet = self.parseRegRet(data: data)
                if (RegModelRet?.id == 0){
                    //self.PopAlert(mess: RegModelRet?.err ?? "Regiter error, please try again!")
                    self.PopAlert(mess: "Registration error, please check your web connection, your information is saved on the iPhone, you can try later")
                    return
                }
                else{
                    self.PopAlert(mess: "We sent you an email to verify it, please check your email to continue!")
                    self.JumpToVerifyEmail()
                }
            }
        }
        task.resume()
        /*
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DobViewController") as! DobViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
    */
    }
 
    func parseRegRet(data: Data) -> RegRetValue? {
        
        var returnValue: RegRetValue?
        do {
            returnValue = try JSONDecoder().decode(RegRetValue.self, from: data)
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
    
    func JumpToVerifyEmail(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "VerifyEmailViewController") as! VerifyEmailViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
