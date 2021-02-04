//
//  SignInViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 1/3/21.
//


import UIKit
import CoreData


struct LogInRetValue: Codable {
    var tipo: String
    var usuario: String
    var ipra: String
    var ipxff: String
    var ipcli: String
    var jwt: String
    var err: String
}


class SignInViewController: UIViewController,  UITextFieldDelegate {
    
    //MARK: Properties

    @IBOutlet weak var nickTextField: UITextField!
    
   
    @IBOutlet weak var pwdTextField: UITextField!
    
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        let nickLoginText = defaults.string(forKey: "LogNick")
        let pwdLoginText = defaults.string(forKey: "LogPwd")
        
        nickTextField.text = nickLoginText
        pwdTextField.text = pwdLoginText
        
        nickTextField?.delegate = self
        pwdTextField?.delegate = self
        
        if nickLoginText != nil && nickLoginText != "" && pwdLoginText != nil  && pwdLoginText != ""{
            signInButton.isEnabled = true
        }
        else{
            signInButton.isEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }

    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        let nickText = nickTextField.text
        let pwdText = pwdTextField.text
        if nickText != "" && pwdText != "" {
            signInButton.isEnabled=true
       }else{
            signInButton.isEnabled=false
       }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
         
        if textField == nickTextField {
            let nickText = updatedString
            let pwdText = pwdTextField.text
            if nickText != "" && pwdText != "" {
                signInButton.isEnabled=true
           }else{
                signInButton.isEnabled=false
           }
        }else{
            let nickText = nickTextField.text
            let pwdText = updatedString
            if nickText != "" && pwdText != "" {
                signInButton.isEnabled=true
           }else{
                signInButton.isEnabled=false
           }
        }
            return true;
        }
    
    func textFieldShouldReturn(_ textField: UITextField)-> Bool{
        // Hide the keyboard
        textField.resignFirstResponder()
        let nickText = self.nickTextField.text
        let pwdText = self.pwdTextField.text
        if (textField == self.nickTextField) {
            textField.resignFirstResponder()
            self.pwdTextField.becomeFirstResponder()
        }
        else{
            if nickText != "" && pwdText != "" {
                if textField == self.pwdTextField {
                    Login(Nick: nickText ?? "",Pwd: pwdText ?? "")
                }
                signInButton.isEnabled=false
           }else{
            signInButton.isEnabled=false
           }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
    }
    
    
    //MARK: Actions

    @IBAction func clickedSingIn(_ sender: Any) {
        let nickText = self.nickTextField.text
        let pwdText = self.pwdTextField.text
        if nickText != "" && pwdText != "" {
            Login(Nick: nickText ?? "",Pwd: pwdText ?? "")
       }
    }
    
    func Login(Nick : String, Pwd: String){
        signInButton.isEnabled=false
        
        let spin = SpinnerViewController()
        // add the spinner view controller
        showSpin(vspin:spin)
       
        var urlString = "https://dossierplus-srv.com/superdeker/api/DoLogin.php/" + (Nick )
        urlString += "/" + Pwd
       
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
            
            let defaults = UserDefaults.standard
            //por default no has corrido la primera vez la app
             defaults.setValue(false, forKey: "FirstRun")

            
            if let error = error {
                print("Error took place \(error)")
                self.signInButton.isEnabled=true
                return
            }
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let _ = String(data: data, encoding: .utf8) {
                let LogModelRet = self.parseRegRet(data: data)
                if (LogModelRet?.tipo == "error"){
                    //self.PopAlert(mess: RegModelRet?.err ?? "Regiter error, please try again!")
                    self.PopAlert(mess: LogModelRet!.err)
                    self.signInButton.isEnabled=true
                   
                    return
                }
                else{
                    if (LogModelRet?.jwt != "" && LogModelRet?.err == ""){
                        DispatchQueue.main.async {
                            //let defaults = UserDefaults.standard
                            //no more showing Welcome String because
                            //defaults.set(false, forKey: "FirstRun" you have been athorized
                             defaults.setValue(true, forKey: "FirstRun")
                            let count = self.CountNotifs()
                            print ("hay \(count) notificaciones registradas")
                            if (count == 0){
                                self.CreateWelcomeNotifs()
                            }
                            self.JumpToMain()
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func JumpToMain(){
        DispatchQueue.main.async {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        //let nextViewController = storyBoard.instantiateViewController(withIdentifier: "CongratulationViewController") as! CongratulationViewController
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "MainScreenTabController") as! UITabBarController
        
        UIApplication.shared.windows.first?.rootViewController = nextViewController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
        
        }
        
    }
    
    func parseRegRet(data: Data) -> LogInRetValue? {
        
        var returnValue: LogInRetValue?
        do {
            returnValue = try JSONDecoder().decode(LogInRetValue.self, from: data)
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
    
    func CountNotifs() -> Int {
        let context = (UIApplication .shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotifAlerts")
        var x = 0
        do{
          try  x = context.count(for: fetchRequest)
        }
        catch {
            
        }
        return x
    }
    
    
    func CreateWelcomeNotifs() {
        let context = (UIApplication .shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let Notif = NotifAlerts(context: context)
          
          Notif.title = "Welcome"
          Notif.contentText = "SuperDeker is the best off-ice training system we've seen.\n\n We use it at all of our schools to build stick handling skills, because plauers can't be on the shakice all day. They are very popular, players are constantly linked up to use them and compete against each other.\n\nTy Gretxky - Founder Gretzky Hockey School"
          Notif.startDate = Date()

          let imag = UIImage(named: "SuperDekerBox")
          Notif.contentImage = imag?.pngData()
        
          Notif.contentType = 0
          do {
              try context.save()
          }
          catch {
          }
        
        let Notif1 = NotifAlerts(context: context)
          
          Notif1.title = "12 Configurable Games"
          Notif1.contentText = "Each game is 45 seconds long just like a pro hockey shift, and just like hockey, you'll never know where you need to pass or stick handle to next."
          Notif1.startDate = Date()

          let imag1 = UIImage(named: "")
          Notif1.contentImage = imag1?.pngData()
        
          Notif1.contentType = 0
          do {
              try context.save()
          }
          catch {
          }
        
    }
}



