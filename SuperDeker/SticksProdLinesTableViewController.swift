//
//  CountriesTableTableViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 11/3/20.
//

import UIKit

class SticksProdLinesTableViewController: UITableViewController {

    struct StickProdLines : Codable {
        var id: String
        var name: String
    }
    
    var JsonFileName = ""
    
    var prodLines: [StickProdLines] = [StickProdLines]()
    //prodLines must have an initial array, or the first time it runs it is going to be empty MOSCA
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let defaults = UserDefaults.standard
        let filename = (defaults.string(forKey: "stickBrand") ?? "") + "-ProdLines"
        print("filename is:" + filename)
        JsonFileName = filename + ".json"
        /*prodLines = loadJsonStickProdLines(fileName: filename) ?? [StickProdLines]()
        
        print("there are " + String(prodLines.count) + " product lines")
        for line in prodLines {
            print(line.name)
        }*/
        self.parseo()
        //self.descargarStickProdLines()
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
        return prodLines.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StickProdCell", for: indexPath)

        // Configure the cell...
        let prodLine = prodLines[indexPath.row]
        cell.textLabel?.text = prodLine.name
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Product Lines"
    }

    /*func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(countries[indexPath.row].name)
        let defaults = UserDefaults.standard
        defaults.set(countries[indexPath.row].name, forKey: "country")
    }*/
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(prodLines[indexPath.row].name)
        if prodLines[indexPath.row].id == "99999" {
            let alertController = UIAlertController(title: "Other Stick", message: "enter your Stick model", preferredStyle: UIAlertController.Style.alert)
            alertController.addTextField { (textField : UITextField!) -> Void in
                textField.placeholder = "Enter model name"
            }
            let saveAction = UIAlertAction(title: "Save", style: UIAlertAction.Style.default, handler: { alert -> Void in
                let otherStick = alertController.textFields![0] as UITextField
                print("Other stick is " + (otherStick.text ?? "") )
                let defaults = UserDefaults.standard
                if (blockList.words.firstIndex(of: (otherStick.text?.lowercased() ?? "") ) != nil) {
                    self.PopAlert(mess: "Word not allowed as Stick model")
                    defaults.set("", forKey: "stickProdLines")
                }
                else{
                    defaults.set((otherStick.text ?? ""), forKey: "stickProdLines")
                    self.navigationController?.popViewController(animated: true)
                }
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: {
                (action : UIAlertAction!) -> Void in })
            
            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
        let defaults = UserDefaults.standard
        defaults.set(prodLines[indexPath.row].name, forKey: "stickProdLines")
        self.navigationController?.popViewController(animated: true)
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

    func loadJsonStickProdLines(fileName: String) -> [StickProdLines]? {
        if let asset = NSDataAsset(name: fileName) {
            let data = asset.data
            let decoder = JSONDecoder()
            let prodLines = try? decoder.decode([StickProdLines].self, from: data)
            return prodLines
        }
       return nil
    }
    
    //-----------------------------Extraer datos del archivo json----------------------------

    func parseo(){

        print ("Parsing")
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationFileUrl = documentsUrl.appendingPathComponent(JsonFileName)
        do {

            let data = try Data(contentsOf: destinationFileUrl, options: [])
            let newProdLines = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []

            //print(blockedwords)
            prodLines.removeAll()
            
            for pline in newProdLines{
                print((pline["name"] as Any) as! String)
                var prodLine: StickProdLines = StickProdLines(id:" 0" , name: "")
                prodLine.id = pline["id"] as! String
                prodLine.name = pline["name"] as! String
                prodLines.append(prodLine)
            }
            let otherbrand: StickProdLines = StickProdLines(id:"99999" , name: "Other")
            prodLines.append(otherbrand)
        }catch {
            print(error)
            prodLines.removeAll()
            let otherbrand: StickProdLines = StickProdLines(id:"99999" , name: "Other")
            prodLines.append(otherbrand)
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
