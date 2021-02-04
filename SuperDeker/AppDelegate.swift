//
//  AppDelegate.swift
//  SuperDeker
//
//  Created by Luis Bermudez on 10/14/20.
//

import UIKit
import CoreData
import UserNotifications
import IQKeyboardManagerSwift


@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        print("llamado desde didFinishLaunchingWithOptions")
        
        func getDocumentsDirectory() -> URL {
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
        }
        
        IQKeyboardManager.shared.enable = true
       
        parseBlockList() // Carga si hay algo en blocklist.json localmente
        
        loadJsonBrandsProdLines(fileName: "stickbrands", nextLevel: "-ProdLines")
        loadJsonBrandsProdLines(fileName: "glovebrands", nextLevel: "-GloveLines")

        descargarblocklist()
        downloadRemoteFile( fileString: "stickbrands.json",nextLevel: "-ProdLines.json")
        downloadRemoteFile( fileString: "glovebrands.json",nextLevel: "-GloveLines.json")

        registerForPushNotifications()
        UNUserNotificationCenter.current().delegate = self
        
        
        // Check if launched from notification
        let notificationOption = launchOptions?[.remoteNotification]
        

        // 1
        if
          let notification = notificationOption as? [String: AnyObject],
          let aps = notification["aps"] as? [String: AnyObject] {
          // 2
          //NewsItem.makeNewsItem(aps)
            addNotifAlerts(aps:aps) // probablemente no se debe llamar, ya que se agrega cuando recibe la notificacion en background
            
          // 3
          (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        }
        
        
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "SuperDeker")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    //------------------Descargar json--------------------------------------------------------
    func descargarblocklist() {
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://dossierplus-srv.com/superdeker/appserver/json/blocklist.json")
        if fileURL != nil {
            // Create destination URL
            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!           //agregar al destino el archivo
            let destinationFileUrl = documentsUrl.appendingPathComponent("blockedwords.json")
            //archivo existente???....................................................
            let fileExists = FileManager().fileExists(atPath: destinationFileUrl.path)
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let request = URLRequest(url:fileURL!)
            // si el archivo centrales.json ya existe, no descargarlo de nuevo y enviar ruta de destino.........................................................................
            
        // si el archivo centrales.json aun no existe, descargarlo y mostrar ruta de destino..........................................................................
            print("descargando archivo blocklist")
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success se ah descargado correctamente...................................
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    print("remote blocklist Status code: \(String(describing: statusCode))")
                    if statusCode == 200 {
                        print(destinationFileUrl)
                        //llamar metodo para parsear el json............................................
                        //self.parseo()
                        if fileExists == true {
                            print("archivo de blocklist existente")
                            print(destinationFileUrl  )
                            do {
                                try FileManager().removeItem(atPath: destinationFileUrl.path)
                                print("Borrado file " + destinationFileUrl.path  )
                            }catch (let writeError) {
                                print("Error removing the file \(destinationFileUrl) : \(writeError)")
                            }
                        }
                        do {
                            // Create destination URL
                            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!

                            let destFileUrl = documentsUrl.appendingPathComponent("blockedwords.json")
                            
                            print("Successfully created blocklist file:")
                            print(destFileUrl)
                             try FileManager.default.copyItem(at: tempLocalUrl, to: destFileUrl)
                            self.parseBlockList()
                        } catch (let writeError) {
                            print("Error creating a file \(destinationFileUrl) : \(writeError)")
                        }
                    }

                } else {
                    print("Error took place while downloading the file blocklist file. Error description: %@", error?.localizedDescription ?? "Error");
                }
            }
            task.resume()
        }
    }



    //-----------------------------Extraer datos del archivo json----------------------------

    func parseBlockList(){
        print ("Parsing Blocklist words from local file blockedwords.json")
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
    }    
   
    func downloadRemoteFile(fileString: String, nextLevel: String) {
        //Create URL to the source file you want to download
        let fileURL = URL(string: "https://dossierplus-srv.com/superdeker/appserver/json/" + fileString)
        if fileURL != nil {
            // Create destination URL
            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
            //agregar al destino el archivo
            let destinationFileUrl = documentsUrl.appendingPathComponent(fileString)
            //archivo existente???....................................................
            let fileExists = FileManager().fileExists(atPath: destinationFileUrl.path)
            print("File " + fileString + " at " + destinationFileUrl.path)
            print (fileExists ? "existe" : "no existe")
            let sessionConfig = URLSessionConfiguration.default
            let session = URLSession(configuration: sessionConfig)
            let request = URLRequest(url:fileURL!)
            // si el archivo centrales.json ya existe, no descargarlo de nuevo y enviar ruta de destino.........................................................................
            
            // si el archivo centrales.json aun no existe, descargarlo y mostrar ruta de destino..........................................................................
            print("descargando archivo " + fileString)
            let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
                if let tempLocalUrl = tempLocalUrl, error == nil {
                    // Success se ah descargado correctamente...................................
                    let statusCode = (response as? HTTPURLResponse)?.statusCode
                    print("remote " + fileString + " Status code: \(String(describing: statusCode))")
                    
                    if statusCode == 200 {
                        print("Successfully downloaded " + fileString + ". Status code: \(String(describing: statusCode))")
                        print(destinationFileUrl)
                        //llamar metodo para parsear el json............................................
                        //self.parseo()
                        if fileExists == true {
                            print("archivo " + fileString + "  existente")
                            print(destinationFileUrl )
                            do {
                                try FileManager().removeItem(atPath: destinationFileUrl.path)
                                print("Borrado local " + fileString + " " + destinationFileUrl.path  )
                            }catch (let writeError) {
                                print("Error removing " + fileString + " \(destinationFileUrl) : \(writeError)")
                            }
                        }
                        do {
                            // Create destination URL
                            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
                            let destFileUrl = documentsUrl.appendingPathComponent(fileString)
                            print("Successfully created " + fileString + ":")
                            print(destFileUrl)
                            try FileManager.default.copyItem(at: tempLocalUrl, to: destFileUrl)
                            //self.parseo()
                            if nextLevel != "" {
                                //parse brands and download prodlines
                                self.parseNextLevel(brands : fileString)
                                for sgbrand in self.prodLines{
                                    self.downloadRemoteFile(fileString: sgbrand + nextLevel, nextLevel: "")
                                }
                            }
                        } catch (let writeError) {
                            print("Error creating " + fileString + "  \(destinationFileUrl) : \(writeError)")
                        }
                    }
                    
                } else {
                    print("Error took place while downloading " + fileString + ". Error description: %@", error?.localizedDescription ?? "Error");
                }
            }
            task.resume()
        }
    }
    
    var prodLines = [String] ()
    
    struct Brands : Codable {
        var id: String
        var name: String
    }
    
    func parseNextLevel(brands : String){
        print ("Parsing")
        let documentsUrl:URL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first! as URL
        let destinationFileUrl = documentsUrl.appendingPathComponent(brands)
        do {

            let data = try Data(contentsOf: destinationFileUrl, options: [])
            let SGBrands = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []

            //print(blockedwords)
            prodLines.removeAll()
            
            for brand in SGBrands{
                print((brand["name"] as Any) as! String)
                //var sgbrand: Brands = Brands(id:" 0" , name: "")
                //sgbrand.id = brand["id"] as! String
                //sgbrand.name = brand["name"] as! String
                prodLines.append(brand["name"] as! String)
            }

        }catch {
            print(error)
        }

    }
        
    struct SGBrands : Codable {
        let id: String
        let name: String
    }
    
    func loadJsonBrandsProdLines(fileName: String, nextLevel: String) {
        print("copying " + fileName + " to local json file" )
        if let asset = NSDataAsset(name: fileName) {
            let data = asset.data
            let decoder = JSONDecoder()
            let brands = try? decoder.decode([SGBrands].self, from: data)
            print ("Brands en assets")
            for brand in (brands ?? [SGBrands]() ) {
                print (brand.name)
            }
            
            let documentsUrl:URL =  (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first as URL?)!
            //agregar al destino el archivo
            let destinationFileUrl = documentsUrl.appendingPathComponent(fileName+".json")
            //archivo existente???....................................................
            let fileExists = FileManager().fileExists(atPath: destinationFileUrl.path)
            print("File " + fileName + " at " + destinationFileUrl.path)
            print (fileExists ? "existe" : "no existe")
            if fileExists { //Mosca cambiar esto a lo contrario
                return
            }
            else{
                //the file must be created with brands as json
                do {
                    try JSONEncoder().encode(brands)
                            .write(to: destinationFileUrl)
                    if nextLevel != "" {
                        for brand in (brands ?? [SGBrands]() ) {
                            loadJsonBrandsProdLines(fileName: brand.name + nextLevel, nextLevel: "")
                        }
                    }
                } catch let error as NSError {
                    print("Array to JSON conversion failed: \(error.localizedDescription)")
                }
            }
            
            return
        }
       return
    }
    
    func registerForPushNotifications() {
      //1
      UNUserNotificationCenter.current()
        .requestAuthorization(
            options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self?.getNotificationSettings()
            DispatchQueue.main.async {
                     UIApplication.shared.registerForRemoteNotifications()
                   }
        }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
      }
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
      let token = tokenParts.joined()
      print("Device Token: \(token)")
    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Push notification received in foreground.")
        //print("WillPresent: \(notification.request.content.userInfo)")
        guard let aps = notification.request.content.userInfo["aps"] as? [String : AnyObject] else {
            return
        }
        print(aps)
        
        addNotifAlerts(aps:aps)
        
        let userInfo = notification.request.content.userInfo
        
        //if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
       // this is sent so the NotifCenters reloads the notification if it is in the front of the stack
        NotificationCenter.default.post(name: Notification.Name("reload"), object: nil, userInfo:userInfo)
         //}
        
        completionHandler([.alert, .sound, .badge])
    }
    
    
    func application(
      _ application: UIApplication,
      didReceiveRemoteNotification userInfo: [AnyHashable: Any],
      fetchCompletionHandler completionHandler:
      @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("notification received check aps")
      guard let aps = userInfo["aps"] as? [String: AnyObject] else {

        completionHandler(.failed)
        return
      }
     addNotifAlerts(aps:aps)
     UIApplication.shared.applicationIconBadgeNumber += 1
        print("trying to add a badge")
        //(window?.rootViewController as? UITabBarController)?.tabBarItem.badgeValue="13"
        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let TabViewController = storyBoard.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        
        
        TabViewController.tabBarItem.badgeValue = "New"
        
      //NewsItem.makeNewsItem(aps)
     completionHandler(.newData)
    }
    
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        
        // 1
        let userInfo = response.notification.request.content.userInfo
        
        guard let aps = userInfo["aps"] as? [String : AnyObject] else {
            return
        }
        print(aps)
        
        addNotifAlerts(aps:aps) // Esto deberia estar comentado,  porque se invoca cuando se le da click a la notificacion y se agrega la notificacion a la lista, pero en realidad se deberia hacer desde el background y listo.
        
        //if UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive {
            NotificationCenter.default.post(name: Notification.Name("reload"), object: nil, userInfo:userInfo)
        //}
       
        // 4
        completionHandler()
        // 666
        /*let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "AlertCenterViewController") as! AlertCenterViewController
        let rootViewController = window?.rootViewController as! UINavigationController
        rootViewController.pushViewController(nextViewController, animated: true)
        */
        
        (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
        //UITabBarController.selectedViewController = [UITabBarController.viewControllers objectAtIndex:1]
        
    }

    
    func addNotifAlerts(aps : [String: AnyObject]){
        let title =  aps["alert"]?["title"] as! String
        let body = aps["alert"]?["body"] as! String
        let date = aps["alert"]?["date"] as! String
        let image = aps["alert"]?["image"] as! String
        let url = aps["alert"]?["url"] as! String
        
        print (title)
        print (body)
        print (date)
        print (image)
        print (url)
        
        
        
        let context = (UIApplication .shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        
        let Notif = NotifAlerts(context: context)
          
          Notif.title = title
          Notif.contentText = body
          Notif.startDate = Date()
        // Create URL
          let imageurl = URL(string: image)!
          var imag = UIImage(named: "")
      
          // Fetch Image Data
          if let data = try? Data(contentsOf: imageurl) {
              // Create Image and Update Image View
              imag = UIImage(data: data)
          }
        
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
        
        UIApplication.shared.applicationIconBadgeNumber += 1
        print("Badge to be updated")
        
        DispatchQueue.main.async {
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let TabViewController = storyBoard.instantiateViewController(withIdentifier: "AlertCenterViewController") as! AlertCenterViewController
            
            //TabViewController.tabBarItem.badgeValue="1"
            
            let tabItem = TabViewController.tabBarItem
            tabItem?.badgeValue = "1"
            
        }
        
        
        //print(tabItem?.title)
        
        
    }
   

    
}

