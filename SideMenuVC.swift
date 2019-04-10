//
//  SideMenuVC.swift
//  SideMenuSwiftDemo
//
//  Created by Kiran Patel on 1/2/16.
//  Copyright © 2016  SOTSYS175. All rights reserved.
//

import Foundation
import UIKit

import SDWebImage
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FirebaseDatabase
import AVFoundation
import NVActivityIndicatorView
import Branch
import FirebaseMessaging



class SideMenuVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
     var window: UIWindow?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var img_Profile: UIImageView!
    @IBOutlet var lbl_titleFollow: UILabel!
    @IBOutlet var btn_Fb: UIButton!
    @IBOutlet var btn_Telegram: UIButton!
    @IBOutlet var btn_Twitter: UIButton!
    @IBOutlet var btn_Instagram: UIButton!
    @IBOutlet var btn_Linkled: UIButton!
    @IBOutlet var btn_YouTube: UIButton!
    @IBOutlet var lbl_Name: UILabel!
    var img_ScreenShot: UIImage!
    
    let imagePicker = UIImagePickerController()
    let recognizer = UITapGestureRecognizer()
    
    
    //, "FAQs", "Rate Us","Invite"
    var arrMenuLogIn = ["Home", "My Profile", "Report issues", "Contact Us","App Rules", "About Us", "Logout"]
    var arrIconLogIn = ["icn_menu_home2","edit-profile_new","icn_menu_reportissue", "icn_sidemenu_contactus","icn_rules", "icn_sidemenu_aboutus", "icn_menu_logout"]
    
  //,"question-mark","icn_rateusnew","icn_invite_sidemenu"
    
   
    override func viewDidAppear(_ animated: Bool) {
        
        
        
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        
        if isLogin == true {
            
            if Connectivity.isConnectedToInternet {
                
                
                
                let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
                
                let userFirst = userDetail!["firstname"] as! String
                let userlast = userDetail!["lastname"] as! String
                
                lbl_Name.text = userFirst + " " + userlast
                
                
                var str_profile : String!
                
                if UserDefaults.standard.object(forKey: "profile") != nil {
                    str_profile = (UserDefaults.standard.object(forKey: "profile") as! String)
                }else {
                    str_profile = ""
                }
                
                if str_profile.count > 0 {
                    
                    let url = URL(string: str_profile!)
                    
                    let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                    vw_Load_BK.backgroundColor = UIColor.black
                    vw_Load_BK.alpha = 0.4
                    self.img_Profile.addSubview(vw_Load_BK)
                    let frame = CGRect(x: (self.img_Profile.frame.width/2)-10, y: (self.img_Profile.frame.height/2)-10, width: 20, height: 20)
                    let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                        type: NVActivityIndicatorType.ballRotateChase)
                    
                    activityIndicatorView.color = UIColor.white
                    self.img_Profile.addSubview(activityIndicatorView)
                    activityIndicatorView.startAnimating()
                    
                    SDWebImageManager.shared().loadImage(
                        with: URL(string: str_profile!),
                        options: .highPriority,
                        progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                            print(isFinished)
                            // remove Indicator
                            if activityIndicatorView != nil {
                                activityIndicatorView.stopAnimating()
                                activityIndicatorView.removeFromSuperview()
                                vw_Load_BK.removeFromSuperview()
                            }
                            if error == nil {
                                
                                self.img_Profile.image = image
                                
                            }else {
                                self.img_Profile.image = UIImage(named: "img_placeholder")
                                
                            }
                    }
                }else {
                    self.img_Profile.image = UIImage(named: "img_placeholder")
                }
                
                
                
            }
            
            
            getProfile()
            
        }else{
            //Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
            self.img_Profile.image = UIImage(named: "img_placeholder")
            
            
        }
        
        
        
        img_ScreenShot = self.takeScreenshot(false)
        
        
        NotificationCenter.default.removeObserver(self, name: Notification.Name("ChangeUserData"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.messagereceived(notification:)), name: NSNotification.Name(rawValue: "ChangeUserData"), object: nil)
        
        
        
    }
    
    
    
    override func viewDidLoad() {
        
        
        super.viewDidLoad()
        self.tableView.reloadData()
        self.tableView.backgroundColor=UIColor.clear
        self.view.backgroundColor=UIColor.white
        
        imagePicker.delegate = self
        
        
        img_Profile.layer.borderWidth = 0.5
        img_Profile.layer.masksToBounds = false
        img_Profile.layer.borderColor = UIColor.white.cgColor
        img_Profile.layer.cornerRadius = img_Profile.frame.height/2
        img_Profile.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        
        img_Profile.addGestureRecognizer(tap)
        
        img_Profile.isUserInteractionEnabled = true
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @objc func messagereceived(notification: Notification) {
        
 
        let isLogin = UserDefaults.standard.bool(forKey: "isLogin")
        
        if isLogin == true {
            if Connectivity.isConnectedToInternet {
                
                 self.getProfile()
                    
            }else{
                Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
                 self.img_Profile.image = UIImage(named: "img_placeholder")
            }
        }else {
             self.img_Profile.image = UIImage(named: "img_placeholder")
        }
        
    }
    
    func getProfile() {
        
        var ref = Database.database().reference() // undeclared
        
        let userDetail: NSDictionary? = KeychainWrapper.standard.object(forKey: ConstantsModel.KeyDefaultUser.userData)! as? NSDictionary
        
        let userID = userDetail!["customerguid"] as! String
        
        if  userDetail!["firstname"] != nil {
            
            let userFirst = userDetail!["firstname"] as! String
            let userlast = userDetail!["lastname"] as! String
            
            lbl_Name.text = userFirst + " " + userlast
        }
        
        
        ref = Database.database().reference().child("profile").child(userID)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            
            if snapshot.exists() {
                
                print(snapshot.value as Any)
                
                let dic_Info = snapshot.value as! String
                print(dic_Info)
                
                if dic_Info != nil {

                    var str_profile = dic_Info





                    if dic_Info  != nil
                    {

                        str_profile = dic_Info 

                    }else{


                        str_profile = ""

                    }


                    UserDefaults.standard.set(str_profile, forKey: "profile")
                    UserDefaults.standard.synchronize()


                    if str_profile.count > 0 {

                        let url = URL(string: str_profile)

                        let vw_Load_BK = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                        vw_Load_BK.backgroundColor = UIColor.black
                        vw_Load_BK.alpha = 0.4
                        self.img_Profile.addSubview(vw_Load_BK)
                        let frame = CGRect(x: (self.img_Profile.frame.width/2)-10, y: (self.img_Profile.frame.height/2)-10, width: 20, height: 20)
                        let activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                            type: NVActivityIndicatorType.ballRotateChase)

                        activityIndicatorView.color = UIColor.white
                        self.img_Profile.addSubview(activityIndicatorView)
                        activityIndicatorView.startAnimating()


                        SDWebImageManager.shared().loadImage(
                            with: URL(string: str_profile),
                            options: .highPriority,
                            progress: nil) { (image, data, error, cacheType, isFinished, imageUrl) in
                                print(isFinished)
                                // remove Indicator
                                if activityIndicatorView != nil {
                                    activityIndicatorView.stopAnimating()
                                    activityIndicatorView.removeFromSuperview()
                                    vw_Load_BK.removeFromSuperview()
                                }
                                if error == nil {

                                    self.img_Profile.image = image

                                }else {
                                    self.img_Profile.image = UIImage(named: "img_placeholder")

                                }
                        }
                    }else {
                        self.img_Profile.image = UIImage(named: "img_placeholder")
                    }


                }
//
                
            }
            
        })
        
    }
    
    @objc private func profileImageHasBeenTapped() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func btn_UserName(_ sender: UIButton){
        
        kConstantObj.SetIntialMainViewController("VDG_QRScanner_ViewController")
    }
    
    //function which is triggered when handleTap is called
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        
        kConstantObj.SetIntialMainViewController("VDG_MyProfile_ViewController")
        
        
    }
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        NSLog("\(info)")
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        imagePickerController(picker, pickedImage: image)
        dismiss(animated: true, completion: nil)
        
        
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, pickedImage: UIImage?) {
        
        
    }
    
    
    
    
    
    func openGallary()
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Permissions Required",
                                                message: "Please grant camera permission from your phone's settings.",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel) { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: { _ in
                    // Handle
                })
            }
        })
        
        present(alertController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        
        return arrMenuLogIn.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let aCell = tableView.dequeueReusableCell(
            withIdentifier: "kCell", for: indexPath)
        
        aCell.backgroundColor=UIColor.clear
        
        let lbl_Menu : UILabel = aCell.viewWithTag(2) as! UILabel
        lbl_Menu.textColor = UIColor.black
        lbl_Menu.font = UIFont(name:Constant.GlobalConstants.themeFontNormal, size: 16.0)
        
        let img_Icon : UIImageView = aCell.viewWithTag(1) as! UIImageView
        
        lbl_Menu.text = arrMenuLogIn[indexPath.row]
        img_Icon.image = UIImage(named: arrIconLogIn[indexPath.row])
        
        
        return aCell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        //self.navigationController?.navigationBar.barTintColor = UIColor.white
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.white]
        
        var str_SelectedMenu: String!
      
        str_SelectedMenu = arrMenuLogIn[indexPath.row];
        if str_SelectedMenu == "Home" {
            kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
        }else if str_SelectedMenu == "Scratch and Win" {
            kConstantObj.SetIntialMainViewController("VDG_ScanNowLoading_ViewController")
        }else if str_SelectedMenu == "FAQs" {
           kConstantObj.SetIntialMainViewController("VDG_FAQ_ViewController")
        }else if str_SelectedMenu == "App Rules" {
            
            kConstantObj.SetIntialMainViewController("VDG_RulesForApp_ViewController")
            
        }else if str_SelectedMenu == "Rate Us" {
            
           kConstantObj.SetIntialMainViewController("VDG_RateUS_ViewController")
      
        }else if str_SelectedMenu == "Contact Us" {
             kConstantObj.SetIntialMainViewController("VDG_MySettings_ViewController")
        }
        else if str_SelectedMenu == "About Us" {
            kConstantObj.SetIntialMainViewController("VDG_AboutUS_ViewController")
        }else if str_SelectedMenu == "My Profile" {
            kConstantObj.SetIntialMainViewController("VDG_MyProfile_ViewController")
        }else if str_SelectedMenu == "Invite" {
            // kConstantObj.SetIntialMainViewController("VDG_Share_ViewController")
            
            GenerateInviteURL.GetURLTemp { (reponse : String) in
                
                if reponse.count > 0 {
                    
                    let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "VDG_Invite_ViewController") as! VDG_Invite_ViewController
                    secondViewController.img_Bk = self.img_ScreenShot
                    secondViewController.str_Invite_URL = reponse
                    secondViewController.str_Invite_Title = "VeriDoc Global"
                    self.present(secondViewController, animated: true)
                }
            }
        }else if str_SelectedMenu == "Report issues" {
            kConstantObj.SetIntialMainViewController("VDG_ReportIssue_ViewController")
        }else if str_SelectedMenu == "Logout" {
         
            
//            let alert = UIAlertController(title: "Are you sure you want to logout?", message: "You will need to login again to use QR code scanner", preferredStyle: UIAlertControllerStyle.alert)
//
//            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
//
//
//            }))
//
//            alert.addAction(UIAlertAction(title: "Logout", style: .default, handler: { action in
//
//                UserDefaults.standard.set(Bool(false), forKey:"isLogin")
//                UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
//                UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
//                UserDefaults.standard.synchronize()
//
//                let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
//
//                print("Remove was successful: \(removeSuccessful)")
//
//                let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
//                self.window?.rootViewController = mainVcIntial
//
//
//            }))
            
            
      
            let attributedString = NSAttributedString(string: "Logout" , attributes: [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 22),
                                                                                   NSAttributedStringKey.foregroundColor : ConstantsModel.ColorCode.kColor_Theme])
            
            let alert = UIAlertController(title: "", message: "Are you sure you want to logout?",  preferredStyle: .alert)
            alert.setValue(attributedString, forKey: "attributedTitle")
            alert.view.tintColor = UIColor.black
            
            let cancelAction = UIAlertAction(title: "Cancel",
                                             style: .default) { (action: UIAlertAction!) -> Void in
            }
            
            let logout = UIAlertAction(title: "Logout",
                                             style: .default) { (action: UIAlertAction!) -> Void in
                                                
                                                                UserDefaults.standard.set(Bool(false), forKey:"isLogin")
                                                                UserDefaults.standard.set(Bool(false), forKey:"isMobileVerified")
                                                                UserDefaults.standard.set(Bool(false), forKey:"isSmartLogin")
                                                                UserDefaults.standard.synchronize()
                                                
                                                                let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: ConstantsModel.KeyDefaultUser.userData)
                                                
                                                                print("Remove was successful: \(removeSuccessful)")
                                                
                                                                let mainVcIntial = kConstantObj.SetIntialMainViewController("VDG_Auth_ViewController")
                                                                self.window?.rootViewController = mainVcIntial
            }
            
            
            alert.addAction(cancelAction)
            alert.addAction(logout)
            
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 57.0
    }
    
    @IBAction func btn_fb(_ sender: UIButton) {
        
        let fbUrl: NSURL = NSURL(string: ConstantsModel.URL_SocialMediaFollow.str_AppFb)!
        let fbWebUrl: NSURL = NSURL(string: ConstantsModel.URL_SocialMediaFollow.str_fb)!
        
        if (UIApplication.shared.canOpenURL(fbUrl as URL)) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(fbUrl as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(fbUrl as URL)
            }
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(fbWebUrl as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(fbWebUrl as URL)
            }
        }
        
        //share_URL(sender: sender.tag)
    }
    
    @IBAction func btn_Telegram(_ sender: UIButton) {
        
        share_URL(sender: sender.tag)
    }
    
    @IBAction func btn_Twitter(_ sender: UIButton) {
        
        share_URL(sender: sender.tag)
    }
    
    @IBAction func btn_Instagram(_ sender: UIButton) {
        
        share_URL(sender: sender.tag)
    }
    
    @IBAction func btn_Linkled(_ sender: UIButton) {
        
        share_URL(sender: sender.tag)
    }
    
    @IBAction func btn_YouTube(_ sender: UIButton) {
        
        //share_URL(sender: sender.tag)\
        
        // https://www.youtube.com/channel/UCbl5uvM3vd-XRm-aDj2YZJw
        
        let fbUrl: NSURL = NSURL(string: "youtube://www.youtube.com/channel/UCbl5uvM3vd-XRm-aDj2YZJw")!
        let fbWebUrl: NSURL = NSURL(string: "https://www.youtube.com/channel/UCbl5uvM3vd-XRm-aDj2YZJw")!
        
        
        
        
        if (UIApplication.shared.canOpenURL(fbUrl as URL)) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(fbUrl as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(fbUrl as URL)
            }
        } else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(fbWebUrl as URL, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
                UIApplication.shared.openURL(fbWebUrl as URL)
            }
        }
        
    }
    
    
    func share_URL(sender : Int){
        
        
        if Connectivity.isConnectedToInternet {
            
            //            let popupvc = PTPopupWebViewController()
            //            .popupAppearStyle(.slide(.bottom, 0.4, true))
            //            .popupDisappearStyle(.slide(.bottom, 0.4, true))
            
            //  popupvc.show()
            
            var str_URL: String!
            
            if sender == 1 {
                //  popupvc.popupView.URL(string: ConstantsModel.URL_SocialMediaFollow.str_fb)
                str_URL = ConstantsModel.URL_SocialMediaFollow.str_fb
            }else  if sender == 2 {
                //  popupvc.popupView.URL(string: ConstantsModel.URL_SocialMediaFollow.str_telegram)
                str_URL = ConstantsModel.URL_SocialMediaFollow.str_instagram
            }else  if sender == 3 {
                // popupvc.popupView.URL(string: ConstantsModel.URL_SocialMediaFollow.str_twitter)
                str_URL = ConstantsModel.URL_SocialMediaFollow.str_twitter
            }else  if sender == 4 {
                //  popupvc.popupView.URL(string: ConstantsModel.URL_SocialMediaFollow.str_instagram)
                str_URL = ConstantsModel.URL_SocialMediaFollow.str_telegram
            }else  if sender == 5 {
                // popupvc.popupView.URL(string: ConstantsModel.URL_SocialMediaFollow.str_linkedln)
                str_URL = ConstantsModel.URL_SocialMediaFollow.str_linkedln
            }else  if sender == 6 {
                // popupvc.popupView.URL(string: ConstantsModel.URL_SocialMediaFollow.str_youtube)
                str_URL = ConstantsModel.URL_SocialMediaFollow.str_youtube
            }else {
                Toast(text: "Url does not found.").show()
            }
            
            guard let url = URL(string: str_URL)
                else {
                    return }
            UIApplication.shared.open(url)
            
            
        }else {
            Toast(text: ConstantsModel.AlertMessage.NetworkConnection).show()
        }
    }
    
    
    func takeScreenshot(_ shouldSave: Bool = true) -> UIImage? {
        
        var screenshotImage :UIImage?
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        guard let context = UIGraphicsGetCurrentContext() else {return nil}
        layer.render(in:context)
        screenshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        if let image = screenshotImage, shouldSave {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
        return screenshotImage
    }
}
