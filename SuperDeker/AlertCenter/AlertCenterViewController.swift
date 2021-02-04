//
//  AlertCenterViewController.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 1/5/21.
//

import UIKit
import CoreData
import Foundation


class AlertNotifCell{
    var TitleLabel : String = ""
    var FullLabel : String = ""
    var DateLabel : String = ""
    var ShowImage : Bool = true
    var ImageName: String = ""
}

var activeCell : Int = 0

class AlertCenterViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var AlertNotifTableView: UITableView!
    @IBOutlet weak var tabBarBell: UITabBarItem!
    
    var AlertNotifs : [AlertNotifCell] = []
    var AllNotifs : [NotifAlerts]?
    
    //reference to managed object context
    let context = (UIApplication .shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("Recs: \(AllNotifs!.count)")
        //return AlertNotifs.count
        return AllNotifs!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlertNotifCell", for: indexPath) as! AlertCenterTableViewCell
        //let cellAtRow = AlertNotifs[indexPath.row]
        let cellAtRow = AllNotifs?[indexPath.row]
        
        cell.AlertTitle.text = cellAtRow?.title
        cell.AlertText.text = cellAtRow?.contentText
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd YYYY"
        cell.AlertDate.text = dateFormatter.string(from:cellAtRow?.startDate ?? Date())
        if cellAtRow?.contentImage == nil{
            cell.AlertImage.image = nil
            //cell.AlertImage.isHidden = true
            var xPos : CGFloat!
            var yPos : CGFloat!
            var width : CGFloat!
            var height : CGFloat!

           xPos = cell.AlertImage.frame.origin.x
           width = cell.AlertImage.frame.size.width
           height = 0//cell.AlertImage.frame.size.height
            yPos = cell.AlertImage.frame.origin.y
                 
            cell.AlertImage.frame = CGRect(x: xPos, y: yPos, width: width, height:height)
            
        }
        else {
            //cell.AlertImage.image = UIImage(named: cellAtRow.ImageName)
            cell.AlertImage.image = UIImage(data:(cellAtRow?.contentImage)!,scale:1.0)
            var xPos : CGFloat!
            var yPos : CGFloat!
            var width : CGFloat!
            var height : CGFloat!

           xPos = cell.AlertImage.frame.origin.x
           width = cell.AlertImage.frame.size.width
           height = cell.AlertImage.frame.size.height
            yPos = cell.AlertImage.frame.origin.y
                 
            cell.AlertImage.frame = CGRect(x: xPos, y: yPos, width: width, height:height)
            
            
        }
        //tableView.beginUpdates()
       let tap = UITapGestureRecognizer(target: self, action: #selector(AlertCenterViewController.someButtonAction))
        cell.AlertShare.addGestureRecognizer(tap)
        cell.AlertShare.isUserInteractionEnabled = true
        cell.AlertShare.tag = indexPath.row
        
        
        let tapT = UITapGestureRecognizer(target: self, action: #selector(AlertCenterViewController.trashButtonAction))
         cell.AlertTrash.addGestureRecognizer(tapT)
         cell.AlertTrash.isUserInteractionEnabled = true
         cell.AlertTrash.tag = indexPath.row

        return cell
    }
    
    @objc func someButtonAction(_ sender:AnyObject) {
        print("Share Button is tapped")
        
        activeCell = sender.view.tag
        
    /*    @NSManaged public var title: String?
        @NSManaged public var contentText: String?
        @NSManaged public var startDate: Date?
        @NSManaged public var contentType: Int64
        @NSManaged public var contentImage: Data?
     */
        
        let someText:AnyObject = (AllNotifs?[activeCell].title ?? "")  + "\n" + (AllNotifs?[activeCell].contentText ?? "")  as AnyObject
        var objectsToShare = UIImage()
        if AllNotifs?[activeCell].contentImage != nil {
            objectsToShare = UIImage(data: AllNotifs?[activeCell].contentImage ?? Data())!
        }

               // set up activity view controller
        
        var sharedObjects:[AnyObject] = [someText ]
        if AllNotifs?[activeCell].contentImage != nil {
            sharedObjects.append (objectsToShare as AnyObject)
        }
            
       let activityViewController = UIActivityViewController(activityItems: sharedObjects, applicationActivities: nil)
       activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash

       // present the view controller
       self.present(activityViewController, animated: true, completion: nil)
    }
    
    
    @objc func trashButtonAction(_ sender:AnyObject) {
        print("Trash Button is tapped")
        activeCell = sender.view.tag
       
        let cellToTrash = AllNotifs![activeCell]
        
        let alert = UIAlertController(title: "Do you want to delete this item?", message: cellToTrash.title, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            
            self.context.delete(cellToTrash)
            
            do {
                try self.context.save()
            }
            catch {
                print("Problem deleting CoreData: " + cellToTrash.title! )
            }
            self.fetchNotifsAlerts()
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
        
    
    }
    
    @objc func updateMessages(notification: NSNotification) {
     print("updating and reloading Notifs")
        print("NOTIFICATION")
        print(notification)
        guard let aps = notification.userInfo?["aps"] as? [String : AnyObject] else {
            return
        }
        addNotifAlerts(aps:aps)
        
         //print(aps?["body"])
   }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        FillAlertNotifs()
        AlertNotifTableView.dataSource = self
        
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateMessages),
                                               name: Notification.Name("reload"),
                                               object: nil)
        UIApplication.shared.applicationIconBadgeNumber = 0
        
    }
    
  
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name("reload"), object: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchNotifsAlerts()
        
    }
    

   
    
    func fetchNotifsAlerts(){
        do{
            self.AllNotifs = try context.fetch(NotifAlerts.fetchRequest())
            
            DispatchQueue.main.async {
                self.AlertNotifTableView.reloadData()
                UIApplication.shared.applicationIconBadgeNumber = 0
            }
        }
        catch {
            
        }
        
    }
    
    func FillAlertNotifs(){
        
        AlertNotifs.append(AlertNotifCell())
        AlertNotifs[AlertNotifs.count-1].TitleLabel = "Welcome"
        AlertNotifs[AlertNotifs.count-1].FullLabel = "SuperDeker is the best off-ice training system we've seen.\n\n We use it at all of our schools to build stick handling skills, because plauers can't be on the ice all day. They are very popular, players are constantly linked up to use them and compete against each other.\n\nTy Gretxky - Founder Gretzky Hockey School"
            
        AlertNotifs[AlertNotifs.count-1].DateLabel = "Dec 22, 2020"
        
        AlertNotifs[AlertNotifs.count-1].ImageName = "SuperDekerBox"
            
        AlertNotifs.append(AlertNotifCell())
        
        AlertNotifs[AlertNotifs.count-1].TitleLabel = "12 Configurable Games"
        AlertNotifs[AlertNotifs.count-1].FullLabel = "Each game is 45 seconds long just like a pro hockey shift, and just like hockey, you'll never know where you need to pass or stick handle to next."
        
        AlertNotifs[AlertNotifs.count-1].DateLabel = "Jan 5, 2021"
         
        AlertNotifs[AlertNotifs.count-1].ShowImage = false
        
        AlertNotifs[AlertNotifs.count-1].ImageName = ""
     
        AlertNotifs.append(AlertNotifCell())
        
        AlertNotifs[AlertNotifs.count-1].TitleLabel = "Tip 1 Stickhandling"
        AlertNotifs[AlertNotifs.count-1].FullLabel = "Focus on the stickhandling techniques your coaches teach for playing on the ice to reinforce"
        
        AlertNotifs[AlertNotifs.count-1].DateLabel = "Jan 7, 2021"
         
        AlertNotifs[AlertNotifs.count-1].ShowImage = true
        
        AlertNotifs[AlertNotifs.count-1].ImageName = "Tip1"
        
        AlertNotifs.append(AlertNotifCell())
        
        AlertNotifs[AlertNotifs.count-1].TitleLabel = "Tip 2 Stickhandling"
        AlertNotifs[AlertNotifs.count-1].FullLabel = "When stickhandling, keep both hands in front of your body. Don't put your top hand ''in the holster''. The normal position should't be next to your hip."
        
        AlertNotifs[AlertNotifs.count-1].DateLabel = "Jan 9, 2021"
         
        AlertNotifs[AlertNotifs.count-1].ShowImage = true
        
        AlertNotifs[AlertNotifs.count-1].ImageName = "Tip2"
        
        AlertNotifs.append(AlertNotifCell())
        
        AlertNotifs[AlertNotifs.count-1].TitleLabel = "No band Tournament 2020"
        AlertNotifs[AlertNotifs.count-1].FullLabel = "We invite you to participate on our special event Tournament that is going to be on 2020 December 18. You can win a set of new Sticks if you are one of the winners. There are 10 days left so go ahead and participate"
        
        AlertNotifs[AlertNotifs.count-1].DateLabel = "Dec 8, 2020"
         
        AlertNotifs[AlertNotifs.count-1].ShowImage = true
        
        AlertNotifs[AlertNotifs.count-1].ImageName = "Tournament1"
        
        // Ahora a grabar estos datos iniciales en Coredata para pruebas, esto debe correr solo una vez
        
      /*let Notif = NotifAlerts(context: context)
        
        Notif.title = AlertNotifs[0].TitleLabel
        Notif.contentText = AlertNotifs[0].FullLabel
        Notif.startDate = Date()
        let imag = UIImage(named: AlertNotifs[0].ImageName)
        Notif.contentImage = imag?.pngData()
        Notif.contentType = 0
            try self.context.save()
        }
        catch {
        }
        
        let Notif2 = NotifAlerts(context: context)
          
          Notif2.title = AlertNotifs[2].TitleLabel
          Notif2.contentText = AlertNotifs[2].FullLabel
          Notif2.startDate = Date()
          let imag2 = UIImage(named: AlertNotifs[2].ImageName)
          Notif2.contentImage = imag2?.pngData()
          Notif2.contentType = 0
          do {
              try self.context.save()
          }
          catch {
          }
   
          let Notif3 = NotifAlerts(context: context)
          
          Notif3.title = AlertNotifs[3].TitleLabel
          Notif3.contentText = AlertNotifs[3].FullLabel
          Notif3.startDate = Date()
          let imag3 = UIImage(named: AlertNotifs[3].ImageName)
          Notif3.contentImage = imag3?.pngData()
          Notif3.contentType = 0
          do {
              try self.context.save()
          }
          catch {
          }
        
        
        let Notif4 = NotifAlerts(context: context)
        
        Notif4.title = AlertNotifs[4].TitleLabel
        Notif4.contentText = AlertNotifs[4].FullLabel
        Notif4.startDate = Date()
        let imag4 = UIImage(named: AlertNotifs[4].ImageName)
        Notif4.contentImage = imag4?.pngData()
        Notif3.contentType = 0
        do {
            try self.context.save()
        }
        catch {
        }
*/
        
        fetchNotifsAlerts()
    }
    
    //Mark: outlets
    
    // MARK: - Table view data source

    
   

    func addNotifAlerts(aps : [String: AnyObject]){
       /* let title =  aps["alert"]?["title"] as! String
        let body = aps["alert"]?["body"] as! String
        let date = aps["alert"]?["date"] as! String
        let image = aps["alert"]?["image"] as! String
        let url = aps["alert"]?["url"] as! String
        
        print (title)
        print (body)
        print (date)
        print (image)
        print (url)
        
        //let context = (UIApplication .shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        let Notif = NotifAlerts(context: context)
          
          Notif.title = title
          Notif.contentText = body
          Notif.startDate = Date()
          let imag = UIImage(named: "")
        if imag == nil {
            Notif.contentImage = Data()
        }
        else {
          Notif.contentImage = imag?.pngData()
        }
          Notif.contentType = 0
          do {
              try context.save()
          }
          catch {
          }
        let nc = NotificationCenter.default
        nc.post(name: aNotification, object: nil)
        */
         do{
            try fetchNotifsAlerts()
        }
        catch{
            print ("error loading Notifications")
        }
    }
    
}
