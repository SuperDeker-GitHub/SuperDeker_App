//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

struct ProfileModel: Codable {
    var Country: String
    var State: String
    var City: String
    var Gender: Bool
    var Hand: String
    var Level: String
    var HeightMode: Bool //Imperial or Metric
    var Heght1: Int
    var Height2: Int
    var WeightMode: Bool
    var Weight: Int
    var StickBrand: String
    var StickProdLine: String
    var GloveBrand: String
    var GloveProdLine: String
}

struct RegProfileRetValue: Codable {
    var id: Int64
    var err: String
}

class ConfirmProfileViewController: UIViewController {
    //MARK: Properties
    
    @IBOutlet weak var LocationLabel: UILabel!
    @IBOutlet weak var GenderLabel: UILabel!
    @IBOutlet weak var StickHandLabel: UILabel!
    @IBOutlet weak var PlayerLevelLabel: UILabel!
    @IBOutlet weak var HeightLabel: UILabel!
    @IBOutlet weak var WeightLabel: UILabel!
    @IBOutlet weak var StickLabel: UILabel!
    @IBOutlet weak var GlovesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        
        let countryText = defaults.string(forKey: "country") ?? ""
        let stateText = defaults.string(forKey: "state")
        let cityText = defaults.string(forKey: "city")
        
        
        LocationLabel.text  = countryText
        LocationLabel.text! += ", " + (stateText ?? "")
        LocationLabel.text! += ", " + (cityText ?? "")
        
        let GenderBool = defaults.bool(forKey: "Gender")
        
        GenderLabel.text = GenderBool ? "Male" : "Female"
        
        let stickHandBool = defaults.bool(forKey: "StickHand")
        StickHandLabel.text = stickHandBool ? "Right" : "Left"
        let playerLevelText = defaults.string(forKey: "PlayerLevel")
        PlayerLevelLabel.text = playerLevelText
        
        let DistanceBool = defaults.bool(forKey: "Distance")
        let FeetSelectionInt = defaults.integer(forKey: "FeetSelection")
        let InchSelectionInt = defaults.integer(forKey: "InchSelection")
        
        if (DistanceBool){
            // Imperial
            HeightLabel.text = String(FeetSelectionInt) + " mt " + String (InchSelectionInt) + " cm"
        }
        else{
            // Metric
            HeightLabel.text = String(FeetSelectionInt) + " ft " + String (InchSelectionInt) + " inches"
        }
        
        let WeightBool = defaults.bool(forKey: "Weight")
        
        let WeightSelectionInt = defaults.integer(forKey: "WeightSelection")
        
        if (WeightBool){
            WeightLabel.text = String(WeightSelectionInt + 60) + " kg"
        }
        else{
            WeightLabel.text = String(WeightSelectionInt + 60) + " lbs"
        }
        let stickBrandText = defaults.string(forKey: "stickBrand")
        let stickProdLinesText = defaults.string(forKey: "stickProdLines")
        StickLabel.text = (stickBrandText ?? "" ) + " " + (stickProdLinesText ?? "")
        let GloveBrandText = defaults.string(forKey: "gloveBrand")
        let GloveProdLinesText = defaults.string(forKey: "gloveProdLines")
        GlovesLabel.text = (GloveBrandText ?? "" ) + " " + (GloveProdLinesText ?? "")
        
    }
    
    //MARK Actions
    
    @IBAction func SaveProfile(_ sender: Any) {
        
        let spin = SpinnerViewController()
        // add the spinner view controller
        showSpin(vspin:spin)
        // register on https://dossierplus-srv.com/superdeker/api/DoSaveProfile.php/NickName/Email/Pwd/DOB
        let defaults = UserDefaults.standard
        
       var Nick = defaults.string(forKey: "Nick") ?? ""
        if Nick == nil || Nick == "" {
            Nick = "AppleID" // This is only temporarily, Nick should never be blanck, this happens when you click Sing up with apple id and never created a Nickname
        }
        
        let countryText = defaults.string(forKey: "country") ?? ""
        let stateText = defaults.string(forKey: "state")
        let cityText = defaults.string(forKey: "city")
        var zipCodeText = defaults.string(forKey: "zipCode" ) ?? ""
        if zipCodeText == "" {
            zipCodeText = "00"
        }
        
        let GenderBool = defaults.bool(forKey: "Gender")
        
        let GenderText = GenderBool ? "Male" : "Female"
        
        let stickHandBool = defaults.bool(forKey: "StickHand")
        let StickHandLabelText = stickHandBool ? "Right" : "Left"
        let playerLevelText = defaults.string(forKey: "PlayerLevel") ?? ""
        
        let DistanceBool = defaults.bool(forKey: "Distance")
        let DistanceText = DistanceBool ? "fts" : "mts"
        let FeetSelectionInt = defaults.integer(forKey: "FeetSelection")
        let InchSelectionInt = defaults.integer(forKey: "InchSelection")
        
        let WeightBool = defaults.bool(forKey: "Weight")
 
        let WeightText = WeightBool ? "kgs" : "lbs"
        
        let WeightSelectionInt = defaults.integer(forKey: "WeightSelection")
        
        let stickBrandText = defaults.string(forKey: "stickBrand") ?? ""
        let stickProdLinesText = defaults.string(forKey: "stickProdLines") ?? ""
        let GloveBrandText = defaults.string(forKey: "gloveBrand") ?? ""
        let GloveProdLinesText = defaults.string(forKey: "gloveProdLines") ?? ""
        
        var urlString = "https://dossierplus-srv.com/superdeker/api/DoSaveProfile.php/" + (Nick ?? "")
        urlString += "/" + countryText
        urlString += "/" + (stateText ?? "")
        urlString += "/" + (cityText ?? "")
        urlString += "/" + zipCodeText
        urlString += "/" + GenderText
        urlString += "/" + StickHandLabelText
        urlString += "/" + playerLevelText
        urlString += "/" + DistanceText
        urlString += "/" + String(FeetSelectionInt)
        urlString += "/" + String(InchSelectionInt)
        urlString += "/" + WeightText
        urlString += "/" + String(WeightSelectionInt + 60)
        urlString += "/" + stickBrandText
        urlString += "/" + stickProdLinesText
        urlString += "/" + GloveBrandText
        urlString += "/" + GloveProdLinesText
        
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        print(urlString)
        
        let url = URL(string: urlString )
        
        print ("Url:")
        print (url ?? "NO HAY")
        
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
                self.PopAlert(mess: "Registration error, please check your web connection, your information is saved on the iPhone, you can try later")
                return
            }
            // Read HTTP Response Status code
            if let response = response as? HTTPURLResponse {
                print("Response HTTP Status code: \(response.statusCode)")
            }
            
            // Convert HTTP Response Data to a simple String
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                let RegModelRet = self.parseRegProfileRet(data: data)
                if (RegModelRet?.id == 0){
                    self.PopAlert(mess: RegModelRet?.err ?? "Registration error, please try again!, Check your web connection, your information is saved on the iPhone you can try later")
                }
                else{
                    self.PopAlert(mess: "Your profile is saved, to update click on Profile in MainScreen !")
                    self.JumpToMainScreen()
                }
            }
        }
        task.resume()
    }
    
    func parseRegProfileRet(data: Data) -> RegProfileRetValue? {
        
        var returnValue: RegProfileRetValue?
        do {
            returnValue = try JSONDecoder().decode(RegProfileRetValue.self, from: data)
        } catch {
            print("Error took place\(error.localizedDescription).")
            returnValue?.id = 0
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
    
    func JumpToMainScreen(){
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let FirstRun = defaults.bool(forKey: "FirstRun")
       
        if (FirstRun == false){
            defaults.set(true, forKey: "FirstRun")
        }
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "TempMainScreen") as! UIViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
