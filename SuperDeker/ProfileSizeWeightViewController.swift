//
//  ViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit

class ProfileSizeWeightViewController: UIViewController, UIPickerViewDelegate , UIPickerViewDataSource {
    
    var pickerData:[[String]] = [[String]]()
    
    var weightData = [Int]()
    
    var pickerFtSelection:Int = 0
    var pickerInchSelection:Int = 0
    var weightIndex: Int = 0

    @IBOutlet weak var distanceSwitch: UISwitch!
    
    @IBOutlet weak var weightSwitch: UISwitch!
    
    @IBOutlet weak var distancePickerView: UIPickerView!
    
    @IBOutlet weak var weightPickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //let img = UIImage(named: "TransSuperDekerLogo")
        //navigationController?.navigationBar.setBackgroundImage(img, for: .default)
           navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.isTranslucent = true
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        let distanceBool = defaults.bool(forKey: "Distance")
        let weightBool = defaults.bool(forKey: "Weight")
        
        
        distanceSwitch.isOn = distanceBool
        weightSwitch.isOn = weightBool
        
        distanceSwitch.tintColor = distanceSwitch.onTintColor
        distanceSwitch.backgroundColor = distanceSwitch.onTintColor
        distanceSwitch.layer.cornerRadius = 16
        
        weightSwitch.tintColor = weightSwitch.onTintColor
        weightSwitch.backgroundColor = weightSwitch.onTintColor
        weightSwitch.layer.cornerRadius = 16
        
        distancePickerView.delegate = self
        distancePickerView.dataSource = self
        weightPickerView.delegate = self
        weightPickerView.dataSource = self
        
        if !distanceSwitch.isOn {
            pickerData = [["0 ft","1 ft","2 ft","3 ft", "4 ft", "5 ft","6 ft","7 ft"],["0 inch" ,"1 inch","2 inches","3 inches","4 inches","5 inches","6 inches","7 inches","8 inches","9 inches","10 inches","11 inches"]]
        }else {
            pickerData = [["0 mts", "1 mt", "2 mt"],["0 cm", "1 cm" ,"2 cm","3 cms","4 cm","5 cm","6 cm","7 cm","8 cm","9 cm","10 cm","11 cm","12 cm", "13 cm","14 cm","15 cm","16 cm", "17 cm","18 cm","19 cm",
                "20 cm","21 cm","22 cm","23 cm","24 cm",
                "25 cm","26 cm","27 cm","28 cm","29 cm",
                "30 cm","31 cm","32 cm","33 cm","34 cm",
                "35 cm","36 cm","37 cm","38 cm","39 cm",
                "40 cm","41 cm","42 cm","43 cm","44 cm",
                "45 cm","46 cm","47 cm","48 cm","49 cm",
                "50 cm","51 cm","52 cm","53 cm","54 cm",
                "55 cm","56 cm","57 cm","58 cm","59 cm",
                "60 cm","61 cm","62 cm","63 cm","64 cm",
                "65 cm","66 cm","67 cm","68 cm","69 cm",
                "70 cm","71 cm","72 cm","73 cm","74 cm",
                "75 cm","76 cm","77 cm","78 cm","79 cm",
                "80 cm","81 cm","82 cm","83 cm","84 cm",
                "85 cm","86 cm","87 cm","88 cm","89 cm",
                "90 cm","91 cm","92 cm","93 cm","94 cm",
                "95 cm","96 cm","97 cm","98 cm","99 cm"
            ]]
        }
        weightData = Array(60...300)
        
        pickerFtSelection = defaults.integer(forKey: "FeetSelection")
        pickerInchSelection = defaults.integer(forKey: "InchSelection")
        
        weightIndex = defaults.integer(forKey: "WeightSelection")
        
        distancePickerView.selectRow(pickerFtSelection, inComponent: 0, animated: true)
        distancePickerView.selectRow(pickerInchSelection, inComponent: 1, animated: true)
       
        weightPickerView.selectRow(weightIndex, inComponent: 0, animated: true)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(distanceSwitch.isOn, forKey: "Distance")
        defaults.set(weightSwitch.isOn, forKey: "Weight")
        defaults.set(pickerFtSelection, forKey: "FeetSelection")
        defaults.set(pickerInchSelection, forKey: "InchSelection")
        defaults.set(weightIndex, forKey: "WeightSelection")
        
    }
    
    //MARK: UIPickerViewDelegate
    
    override func didReceiveMemoryWarning(){
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == distancePickerView{
            return 2
        }
        if pickerView == weightPickerView{
            return 1
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == distancePickerView{
            return pickerData[component].count
        }
        if pickerView == weightPickerView{
            return weightData.count
        }
        return 0
    }
    
    func pickerView(_ pickerView:UIPickerView,titleForRow row:Int, forComponent component:Int) -> String?{
        if pickerView == distancePickerView{
            return pickerData[component][row]
        }
        if pickerView == weightPickerView{
            return String(weightData[row])
        }
        return ""
    }
    
    func pickerView(_ pickerView:UIPickerView,didSelectRow row:Int, inComponent component:Int){
        if pickerView == distancePickerView{
            if component == 0 {
                pickerFtSelection = row
            }
            if component == 1{
                pickerInchSelection = row
            }
        }
        if pickerView == weightPickerView{
            weightIndex = row
        }
    }
    //MARK Actions
    
    @IBAction func ProfileGenderDone(_ sender: Any) {
    }
    
    @IBAction func ChangeHeightImperialMetric(_ sender: Any) {
        if !distanceSwitch.isOn {
            let cm = pickerFtSelection * 100 + pickerInchSelection
            print ("Cm:" + String(cm))
            pickerData = [["0 ft","1 ft","2 ft","3 ft", "4 ft", "5 ft","6 ft","7 ft"],["0 inch" ,"1 inch","2 inches","3 inches","4 inches","5 inches","6 inches","7 inches","8 inches","9 inches","10 inches","11 inches"]]
            let inches = Int(Double(cm)/2.54 + 0.5)
            print ("Inches:" + String(inches))
            let feet = Int(inches/12)
            print ("feet:" + String(feet))
            let inchesresiduales = inches - (feet*12)
            print ("Inches Residuales:" + String(inchesresiduales))
            pickerFtSelection = feet
            print("0-Selection" + String(pickerFtSelection))
            pickerInchSelection = inchesresiduales
            print("1-Selection" + String(pickerInchSelection))
            if pickerFtSelection >= 8 {
                pickerFtSelection = 7
                pickerInchSelection = 11
            }
        }else {
            let feet = pickerFtSelection
            let inches = pickerInchSelection + feet*12
            let cm = Int(Double(inches) * 2.54 + 0.5)
            pickerFtSelection = Int(cm/100)
            pickerInchSelection = cm - pickerFtSelection * 100 
            
            pickerData = [["0 mts", "1 mt", "2 mt"],["0 cm", "1 cm" ,"2 cm","3 cms","4 cm","5 cm","6 cm","7 cm","8 cm","9 cm","10 cm","11 cm","12 cm", "13 cm","14 cm","15 cm","16 cm", "17 cm","18 cm","19 cm",
                "20 cm","21 cm","22 cm","23 cm","24 cm",
                "25 cm","26 cm","27 cm","28 cm","29 cm",
                "30 cm","31 cm","32 cm","33 cm","34 cm",
                "35 cm","36 cm","37 cm","38 cm","39 cm",
                "40 cm","41 cm","42 cm","43 cm","44 cm",
                "45 cm","46 cm","47 cm","48 cm","49 cm",
                "50 cm","51 cm","52 cm","53 cm","54 cm",
                "55 cm","56 cm","57 cm","58 cm","59 cm",
                "60 cm","61 cm","62 cm","63 cm","64 cm",
                "65 cm","66 cm","67 cm","68 cm","69 cm",
                "70 cm","71 cm","72 cm","73 cm","74 cm",
                "75 cm","76 cm","77 cm","78 cm","79 cm",
                "80 cm","81 cm","82 cm","83 cm","84 cm",
                "85 cm","86 cm","87 cm","88 cm","89 cm",
                "90 cm","91 cm","92 cm","93 cm","94 cm",
                "95 cm","96 cm","97 cm","98 cm","99 cm"
            ]]
            
        }
        distancePickerView.reloadAllComponents()
        distancePickerView.selectRow(pickerFtSelection, inComponent: 0, animated: true)
        distancePickerView.selectRow(pickerInchSelection, inComponent: 1, animated: true)
    }
    
    @IBAction func ChangeWeightImperialMetric(_ sender: Any) {
        if !weightSwitch.isOn {
            //lbs
            let kilos = weightData[weightIndex]
            print("Kilos:" + String(kilos))
            let lbs = Int(Double(kilos) * 2.20462 + 0.5)
            print("Lbs:" + String(lbs))
            if let index = weightData.firstIndex(of: lbs) {
                weightPickerView.selectRow(index, inComponent: 0, animated: true)
                weightIndex = index
            }
        }else {
            let lbs = weightData[weightIndex]
            print("Lbs:" + String(lbs))
            let kilos = Int(Double(lbs) / 2.20462 + 0.5)
            print("Kilos:" + String(kilos))
            if let index = weightData.firstIndex(of: kilos) {
                weightPickerView.selectRow(index, inComponent: 0, animated: true)
                weightIndex = index
            }
        }
        
    }
    
    func JumpToDOB(){
        DispatchQueue.main.async {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DobViewController") as! DobViewController
            self.navigationController?.pushViewController(nextViewController, animated: true)
        }
    }
}
