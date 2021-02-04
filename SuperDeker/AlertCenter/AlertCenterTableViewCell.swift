//
//  AlertCenterTableViewCell.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 1/5/21.
//

import UIKit

class AlertCenterTableViewCell: UITableViewCell {

    @IBOutlet weak var AlertTitle: UILabel!
    
    @IBOutlet weak var AlertText: UILabel!
    @IBOutlet weak var AlertImage: UIImageView!
    @IBOutlet weak var AlertDate: UILabel!

    @IBOutlet weak var AlertThumbUo: UIImageView!
    
    @IBOutlet weak var AlertShare: UIImageView!
    
    @IBOutlet weak var AlertTrash: UIImageView!
    
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
           // configureView()
        

        }
   
}
