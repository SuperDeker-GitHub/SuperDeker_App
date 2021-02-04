//
//  WeightPickerViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 11/3/20.
//

import UIKit

class WeightPickerViewController: UIViewController , UIPickerViewDelegate {

    @IBOutlet weak var weightSegueLabel: UILabel!
    
    let feet = Array(1...7)
    let inches = Array(0...11)

    var recievedString: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        weightSegueLabel.text = recievedString
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {

        return 2

    }

    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //row = [repeatPickerView selectedRowInComponent:0];
        var row = pickerView.selectedRowInComponent(0)
        println("this is the pickerView\(row)")

        if component == 0 {
            return feet.count
        }

        else {
            return inches.count
        }

    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {

        if component == 0 {
        return String(feet[row])
        } else {

        return String(inches[row])
            
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
