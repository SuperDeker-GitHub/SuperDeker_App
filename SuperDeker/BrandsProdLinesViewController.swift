//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class BrandsProdLinesViewController: UIViewController {
    //MARK: Properties
     
    @IBOutlet weak var stickBrandButton: UIButton!
    
    @IBOutlet weak var prodLinesButton: UIButton!
    
    @IBOutlet weak var gloveBrandsButton: UIButton!

    @IBOutlet weak var gloveProdLinesButton: UIButton!
    
    var JsonStickProdLines = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
           //navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            //navigationController?.navigationBar.shadowImage = UIImage()
            //navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        
    }
    //MARK Actions
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        let defaults = UserDefaults.standard
        let brand = defaults.string(forKey: "stickBrand")
        if brand == nil || brand == "" {
            stickBrandButton.setTitle("Click to select Stick Brand >", for: .normal)
            let prodLine = defaults.string(forKey: "stickProdLines")
            if prodLine == nil || prodLine == "" {
                prodLinesButton.setTitle("Click to select Stick >", for: .normal)
            }
        }
        else{
            stickBrandButton.setTitle(brand, for: .normal)
            let prodLine = defaults.string(forKey: "stickProdLines")
            if prodLine == nil || prodLine == "" {
                prodLinesButton.setTitle("Click to select Stick >", for: .normal)
            }
            else{
                prodLinesButton.setTitle(prodLine, for: .normal)
                //JsonStickProdLines = (brand ?? "") + "-ProdLines.json"
                //self.descargaStickProdLines()
            }

        }
        let gloveBrand = defaults.string(forKey: "gloveBrand")
        if gloveBrand == nil || gloveBrand == "" {
            gloveBrandsButton.setTitle("Click to select Glove Brand >", for: .normal)
            let gloveLine = defaults.string(forKey: "gloveProdLines")
            if gloveLine == nil || gloveLine == "" {
                gloveProdLinesButton
                    .setTitle("Click to select Glove >", for: .normal)
            }
        }
        else{
            gloveBrandsButton.setTitle(gloveBrand, for: .normal)
            let gloveLine = defaults.string(forKey: "gloveProdLines")
            if gloveLine == nil || gloveLine == "" {
                gloveProdLinesButton
                    .setTitle("Click to select Glove >", for: .normal)
            }
            else{
                gloveProdLinesButton.setTitle(gloveLine, for: .normal)
            }

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
