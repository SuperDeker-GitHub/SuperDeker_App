//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit


struct NickModel: Codable {
    let nicksaved: String
    let used: Bool
}

class NicknameViewController: UIViewController, UITextFieldDelegate {
    //MARK: Properties

    @IBOutlet weak var nicknameEditField: UITextField!
    @IBOutlet weak var nicknameFormat: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
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
        nicknameEditField.text = nickText
        nicknameEditField?.delegate = self;
        if conformsToNickname(nick: nickText ?? ""){
            saveButton.isEnabled=true
        }else{
            saveButton.isEnabled=false
        }
       //updateBlockList()
    }
    override func viewDidDisappear(_ animated: Bool) {
        let nick = nicknameEditField.text
        let defaults = UserDefaults.standard
        defaults.set(nick, forKey: "NickName")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //descargarblocklist()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        let text = textField.text ?? ""
        
        if conformsToNickname(nick: text){
            saveButton.isEnabled=true
        }else{
            saveButton.isEnabled=false
        }
        //print("StartedEdigint")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
         if conformsToNickname(nick: updatedString ?? ""){
            saveButton.isEnabled=true
        }else{
            saveButton.isEnabled=false
        }
        return (updatedString?.count ?? 0) <= 15;
        }
    
    func textFieldShouldReturn(_ textField: UITextField)-> Bool{
        // Hide the keyboard
        textField.resignFirstResponder()
        let text = textField.text ?? ""
        
        if conformsToNickname(nick: text){
            nickNameDone(saveButton)
        }else{
            if (blockList.words.firstIndex(of: text.lowercased()) != nil) {
                self.PopAlert(mess: "This nickname is not allowed")
                return true
            }
            saveButton.isEnabled=false
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        textField.resignFirstResponder()
        
        
    }
    
    
    func conformsToNickname(nick: String)-> Bool{
        //una sola palabra de 4 o más caracteres, hasta 20
        if nick.count < 1 || nick.count > 15 {
            nicknameFormat.text="Nickname must be 1 characters or more up to 15"
            return false
        }
        if nick.contains(" ") {
            nicknameFormat.text="Nickname must be 1 word"
            return false
        }
        if (blockList.words.firstIndex(of: nick.lowercased()) != nil) {
            nicknameFormat.text="Word not allowed"
            return false
        }
        nicknameFormat.text=""
        return true
    }
    //MARK Actions
    
    @IBAction func nickNameDone(_ sender: UIBarButtonItem) {
        
        let spin = SpinnerViewController()
        // add the spinner view controller
        showSpin(vspin:spin)
        
        // checking on https://dossierplus-srv.com/superdeker/api/CheckNicknameUsed.php/NickName
        let nick = nicknameEditField.text ?? ""
        
        // Create URL
        let url = URL(string: "https://dossierplus-srv.com/superdeker/api/CheckNicknameUsed.php/"+nick)
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
                let nickNew=self.parseNickModel(data: data)
                let used = nickNew?.used
                if (used ?? false){
                    self.PopAlert(mess: "This nickname is already used, try another one")
                }
                else{
                    let defaults = UserDefaults.standard
                    defaults.set(nick, forKey: "NickName")
                    self.JumpToDOB()
                }
                print("Nicksave:"+nickNew!.nicksaved )
                print("used:" + (nickNew!.used ? "true":"false"))
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
    
    func parseNickModel(data: Data) -> NickModel? {
        
        var returnValue: NickModel?
        do {
            returnValue = try JSONDecoder().decode(NickModel.self, from: data)
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
    
    
    func JumpToDOB(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DobViewController") as! DobViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
    func updateBlockList(){
        blockedWords = loadJsonBlockedWords(fileName: "blocklist") ?? [blockword]()
        blockList.words = [String]()
        for word in blockedWords {
            blockList.words.append(word.value)
        }
    }
    func loadJsonBlockedWords(fileName: String) -> [blockword]? {
        if let asset = NSDataAsset(name: fileName) {
            let data = asset.data
            let decoder = JSONDecoder()
            let stickBrands = try? decoder.decode([blockword].self, from: data)
            return stickBrands
        }
       return nil
    }
    /*func descargarblocklist() {

        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://dossierplus-srv.com/superdeker/appserver/json/blocklist.json")

        // Create destination URL
        let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!

        //agregar al destino el archivo
        let destinationFileUrl = documentsUrl.appendingPathComponent("blockedwords.json")

        //archivo existente???....................................................
        let fileExists = FileManager().fileExists(atPath: destinationFileUrl.path)

        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)

        let request = URLRequest(url:fileURL!)

        // si el archivo centrales.json ya existe, no descargarlo de nuevo y enviar ruta de destino.........................................................................
        if fileExists == true {
            print("archivo existente")
            print(destinationFileUrl  )
            do {
                try FileManager().removeItem(atPath: destinationFileUrl.path)
                print("Borrado file " + destinationFileUrl.path  )
            }catch (let writeError) {
                print("Error removing the file \(destinationFileUrl) : \(writeError)")
            }
            
        }

    // si el archivo centrales.json aun no existe, descargarlo y mostrar ruta de destino..........................................................................
        if 1 == 1 {
            print("descargar archivo")

        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success se ah descargado correctamente...................................
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Successfully downloaded. Status code: \(statusCode)")
                    print(destinationFileUrl)
                    //llamar metodo para parsear el json............................................
                    //self.parseo()
                }

                do {
                    // Create destination URL
                    let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!

                    let destFileUrl = documentsUrl.appendingPathComponent("blockedwords.json")
                    
                    print("Successfully created:")
                    print(destFileUrl)
                    
                   
                    try FileManager.default.copyItem(at: tempLocalUrl, to: destFileUrl)
                    self.parseo()
                } catch (let writeError) {
                    print("Error creating a file \(destinationFileUrl) : \(writeError)")
                }

            } else {
                print("Error took place while downloading a file. Error description: %@", error?.localizedDescription ?? "Error");
            }
            }
        task.resume()

        }}




    //-----------------------------Extraer datos del archivo json----------------------------

    func parseo(){

        print ("Parsing")
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationFileUrl = documentsUrl.appendingPathComponent("blockedwords.json")
        do {

            let data = try Data(contentsOf: destinationFileUrl, options: [])
            let blockedwords = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []

            //print(blockedwords)
            blockList.words.removeAll()
            
            for word in blockedwords{
                print((word["value"] as Any) as! String)
                blockList.words.append((word["value"] as Any) as! String)
            }

        }catch {
            print(error)
        }

    }*/
}
