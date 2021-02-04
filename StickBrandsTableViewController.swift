//
//  CountriesTableTableViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 11/3/20.
//

import UIKit

class StickBrandsTableViewController: UITableViewController {

    struct StickBrands : Codable {
        var id: String
        var name: String
    }
    
    var stickBrands: [StickBrands] = [StickBrands]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //self.navigationController?.navigationBar
        self.parseStickBrands()
        /* stickBrands = loadJsonStickBrands(fileName: "StickBrands") ?? [StickBrands]()
        
        print("there are " + String(stickBrands.count) + " Strick Brands")
        for brand in stickBrands {
            print(brand.name)
        }*/
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
     
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return stickBrands.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StickBrandsCell", for: indexPath)

        // Configure the cell...
        let brand = stickBrands[indexPath.row]
        cell.textLabel?.text = brand.name
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Stick Brands"
    }

    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(countries[indexPath.row].name)
        let defaults = UserDefaults.standard
        defaults.set(countries[indexPath.row].name, forKey: "country")
    }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(stickBrands[indexPath.row].name)
        if stickBrands[indexPath.row].id == "99999" {
            let alertController = UIAlertController(title: "Other Stick Brand", message: "enter you brand", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter brand name"
            }
            let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let otherBrand = alertController.textFields![0] as UITextField
                print("Other brand is " + (otherBrand.text ?? "") )
                let defaults = UserDefaults.standard
                if (blockList.words.firstIndex(of: (otherBrand.text?.lowercased() ?? "") ) != nil) {
                    self.PopAlert(mess: "Word not allowed as Brand")
                    defaults.set("", forKey: "stickBrand")
                    defaults.set("", forKey: "stickProdLines")
                }
                else {
                    defaults.set((otherBrand.text ?? ""), forKey: "stickBrand")
                    defaults.set("", forKey: "stickProdLines")
                    self.navigationController?.popViewController(animated: true)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            let defaults = UserDefaults.standard
            defaults.set(stickBrands[indexPath.row].name, forKey: "stickBrand")
            defaults.set("", forKey: "stickProdLines")
            self.navigationController?.popViewController(animated: true)
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func loadJsonStickBrands(fileName: String) -> [StickBrands]? {
        if let asset = NSDataAsset(name: fileName) {
            let data = asset.data
            let decoder = JSONDecoder()
            let stickBrands = try? decoder.decode([StickBrands].self, from: data)
            return stickBrands
        }
       return nil
    }
    
    
    //-----------------------------Extraer datos del archivo json----------------------------

    func parseStickBrands(){

        print ("Parsing")
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationFileUrl = documentsUrl.appendingPathComponent("stickbrands.json")
        do {

            let data = try Data(contentsOf: destinationFileUrl, options: [])
            let newStickBrands = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []

            //print(blockedwords)
            stickBrands.removeAll()
            
            for brand in newStickBrands{
                print((brand["name"] as Any) as! String)
                var stickbrand: StickBrands = StickBrands(id:"0" , name: "")
                stickbrand.id = brand["id"] as! String
                stickbrand.name = brand["name"] as! String
                stickBrands.append(stickbrand)
            }
            let otherbrand: StickBrands = StickBrands(id:"99999" , name: "Other")
            stickBrands.append(otherbrand)

        }catch {
            print(error)
            stickBrands.removeAll()
            let otherbrand: StickBrands = StickBrands(id:"99999" , name: "Other")
            stickBrands.append(otherbrand)
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
}
